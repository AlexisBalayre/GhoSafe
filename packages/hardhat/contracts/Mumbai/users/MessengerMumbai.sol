// File: contracts/Mumbai/users/MessengerMumbai.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { CCIPReceiver } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import { IMessengerMumbai } from "../interfaces/IMessengerMumbai.sol";
import { IAccessManagerMumbai } from "../interfaces/IAccessManagerMumbai.sol";
import { ILoanSafeMumbai } from "../interfaces/ILoanSafeMumbai.sol";

/**
 * @title MessengerMumbai Contract
 * @author GhoSafe Protocol
 * @notice Contract for sending/receiving string data across chains.
 * @dev This contract should be deployed by the SafeMumbai contract.
 */
contract MessengerMumbai is IMessengerMumbai, CCIPReceiver {
	using SafeERC20 for IERC20;

	/// @notice Access manager contract.
	IAccessManagerMumbai public immutable USER_ACCESS_MANAGER;

	/// @notice LoanSafe contract.
	ILoanSafeMumbai public immutable USER_LOAN_SAFE;

	/// @notice Mapping of message IDs to messages.
	mapping(bytes32 => string) public messageIdToText;

	/// @notice Mapping to keep track of allowlisted destination chains.
	mapping(uint64 => bool) public allowlistedDestinationChains;

	/// @notice Mapping to keep track of allowlisted source chains.
	mapping(uint64 => bool) public allowlistedSourceChains;

	/// @notice Mapping to keep track of allowlisted senders.
	mapping(address => bool) public allowlistedSenders;

	/// @dev Mapping of loan IDs to loan data.
	mapping(uint256 => LoanData) private loanData;

	/// @notice Link Token.
	IERC20 private LINK_TOKEN;

	/**
	 * @notice Constructor initializes the contract with the router address.
	 * @param _router The address of the router contract.
	 * @param _link The address of the link contract.
	 * @param _accessManager The address of the access manager contract.
	 */
	constructor(
		address _router,
		address _link,
		IAccessManagerMumbai _accessManager
	) CCIPReceiver(_router) {
		LINK_TOKEN = IERC20(_link);
		USER_ACCESS_MANAGER = _accessManager;
		USER_LOAN_SAFE = ILoanSafeMumbai(msg.sender);
	}

	/**
	 * @dev Modifier that checks if the chain with the given destinationChainSelector is allowlisted.
	 * @param _destinationChainSelector The selector of the destination chain.
	 */
	modifier onlyAllowlistedDestinationChain(uint64 _destinationChainSelector) {
		if (!allowlistedDestinationChains[_destinationChainSelector])
			revert DestinationChainNotAllowlisted(_destinationChainSelector);
		_;
	}

	/**
	 * @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
	 * @param _sourceChainSelector The selector of the destination chain.
	 * @param _sender The address of the sender.
	 */
	modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
		if (!allowlistedSourceChains[_sourceChainSelector])
			revert SourceChainNotAllowlisted(_sourceChainSelector);
		if (!allowlistedSenders[_sender]) revert SenderNotAllowlisted(_sender);
		_;
	}

	/**
	 * @dev Modifier that checks if the sender is the owner.
	 */
	modifier onlyOwner() {
		if (!USER_ACCESS_MANAGER.hasRole(keccak256("OWNER_ROLE"), msg.sender)) {
			revert OnlyOwnerCanCall(msg.sender);
		}
		_;
	}

	/**
	 * @notice Returns the loan data for a given loan ID.
	 * @param _loanId ID of the loan.
	 * @return LoanData Loan data.
	 */
	function getLoanData(
		uint256 _loanId
	) external view returns (LoanData memory) {
		return loanData[_loanId];
	}

	/**
	 * @notice Allows the contract owner to update the allowlist status of a destination chain for transactions.
	 * @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
	 * @param _allowed The new allowlist status.
	 * @dev This function reverts if the sender is not the owner.
	 */
	function allowlistDestinationChain(
		uint64 _destinationChainSelector,
		bool _allowed
	) external override onlyOwner {
		allowlistedDestinationChains[_destinationChainSelector] = _allowed;
	}

	/**
	 * @notice Allows the contract owner to update the allowlist status of a source chain for transactions.
	 * @param _sourceChainSelector The identifier (aka selector) for the source blockchain.
	 * @param _allowed The new allowlist status.
	 * @dev This function reverts if the sender is not the owner.
	 */
	function allowlistSourceChain(
		uint64 _sourceChainSelector,
		bool _allowed
	) external override onlyOwner {
		allowlistedSourceChains[_sourceChainSelector] = _allowed;
	}

	/**
	 * @notice Allows the contract owner to update the allowlist status of a sender for transactions.
	 * @param _sender The address of the sender.
	 * @param _allowed The new allowlist status.
	 * @dev This function reverts if the sender is not the owner.
	 */
	function allowlistSender(
		address _sender,
		bool _allowed
	) external override onlyOwner {
		allowlistedSenders[_sender] = _allowed;
	}

	/**
	 * @notice Send Data to another chain.
	 * @dev The contract should have sufficient LINK.
	 * @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
	 * @param _loanId ID of the loan.
	 * @param _receiver The address of the recipient on the destination blockchain.
	 */
	function sendData(
		uint64 _destinationChainSelector,
		uint256 _loanId,
		address _receiver
	) external onlyAllowlistedDestinationChain(_destinationChainSelector) {
		// Only the LoanManager contract can send messages
		if (!USER_ACCESS_MANAGER.hasRole(keccak256("OWNER_ROLE"), msg.sender)) {
			revert OnlyLoanManagerCanCall(msg.sender);
		}

		// Get the loan data
		LoanData memory loan = loanData[_loanId];

		// Encode the message struct into bytes
		bytes memory data = abi.encode(
			Response({
				loanId: _loanId,
				action: loan.lastAction,
				isSuccessful: loan.isSuccessful
			})
		);

		// Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
		Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
			_receiver,
			data,
			address(LINK_TOKEN)
		);

		// Initialize a router client instance to interact with cross-chain router
		IRouterClient router = IRouterClient(this.getRouter());

		// Get the fee required to send the CCIP message
		uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

		if (fees > LINK_TOKEN.balanceOf(address(this)))
			revert NotEnoughBalance(LINK_TOKEN.balanceOf(address(this)), fees);

		// approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
		LINK_TOKEN.approve(address(router), fees);

		// Send the CCIP message through the router and store the returned CCIP message ID
		router.ccipSend(
			_destinationChainSelector,
			evm2AnyMessage
		);
	}

	/**
	 * @dev This function is called by the router when a CCIP message is received.
	 * @param any2EvmMessage Received message
	 */
	function _ccipReceive(
		Client.Any2EVMMessage memory any2EvmMessage
	)
		internal
		override
		onlyAllowlisted(
			any2EvmMessage.sourceChainSelector,
			abi.decode(any2EvmMessage.sender, (address))
		) // Make sure source chain and sender are allowlisted
	{
		bool isSuccessful;

		// Decode the message data into a Request struct
		Request memory request = abi.decode(any2EvmMessage.data, (Request));

		// Borrow Action
		if (request.action == 0) {
			// Init Data
			USER_LOAN_SAFE.setLoanData(
				request.loanId,
				request.collateralIdOrAmount,
				request.collateralType,
				request.collateralAddress,
				request.borrower
			);

			// Transfer collateral to this contract.
			if (!request.collateralType) {
				IERC20(request.collateralAddress).safeTransferFrom(
					request.borrower,
					address(USER_LOAN_SAFE),
					request.collateralIdOrAmount
				);
			} else {
				IERC721(request.collateralAddress).safeTransferFrom(
					request.borrower,
					address(USER_LOAN_SAFE),
					request.collateralIdOrAmount
				);
			}
			isSuccessful = true;
		}
		// Repay Action
		else if (request.action == 1) {
			USER_LOAN_SAFE.sendBackCollateral(request.loanId);
			isSuccessful = true;
		}
		// Liquidate Action
		else if (request.action == 2) {
			USER_LOAN_SAFE.seizeCollateral(request.loanId, request.borrower);
			isSuccessful = true;
		}

		// Emit an event with message details
		emit MessageReceived(
			any2EvmMessage.messageId,
			any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
			abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
			request.loanId,
			request.action,
			isSuccessful
		);

		// Store data
		loanData[request.loanId].lastAction = request.action;
		loanData[request.loanId].isSuccessful = isSuccessful;
	}

	/**
	 * @notice Constructs a CCIP message.
	 * @dev This function will create an EVM2AnyMessage struct with all the necessary information for sending a text.
	 * @param _receiver The address of the receiver.
	 * @param _data The bytes data to be sent.
	 * @param _feeTokenAddress The address of the token used for fees. Set address(0) for native gas.
	 * @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
	 */
	function _buildCCIPMessage(
		address _receiver,
		bytes memory _data,
		address _feeTokenAddress
	) internal pure returns (Client.EVM2AnyMessage memory) {
		// Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
		return
			Client.EVM2AnyMessage({
				receiver: abi.encode(_receiver), // ABI-encoded receiver address
				data: _data, // Already encoded data
				tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array aas no tokens are transferred
				extraArgs: Client._argsToBytes(
					// Additional arguments, setting gas limit
					Client.EVMExtraArgsV1({ gasLimit: 200_000 })
				),
				// Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
				feeToken: _feeTokenAddress
			});
	}

	/**
	 * @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token.
	 * @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
	 * @param _beneficiary The address to which the tokens will be sent.
	 * @param _token The contract address of the ERC20 token to be withdrawn.
	 */
	function withdrawToken(
		address _beneficiary,
		address _token
	) public onlyOwner {
		// Retrieve the balance of this contract
		uint256 amount = IERC20(_token).balanceOf(address(this));

		// Revert if there is nothing to withdraw
		if (amount == 0) revert NothingToWithdraw();

		IERC20(_token).transfer(_beneficiary, amount);
	}
}
