// File: contracts/Sepolia/users/MessengerSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { CCIPReceiver } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { IERC20 } from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";

import { IMessengerSepolia } from "../interfaces/IMessengerSepolia.sol";
import { ILoanManagerSepolia } from "../interfaces/ILoanManagerSepolia.sol";
import { IAccessManagerSepolia } from "../interfaces/IAccessManagerSepolia.sol";

/**
 * @title MessengerSepolia Contract
 * @author GhoSafe Protocol
 * @notice Contract for transferring messages between chains
 * @dev This contract should be deployed by the SafeSepolia contract.
 */
contract MessengerSepolia is IMessengerSepolia, CCIPReceiver {
	/// @notice Loan manager contract.
	ILoanManagerSepolia public immutable USER_LOAN_MANAGER;

	/// @notice Access manager contract.
	IAccessManagerSepolia public immutable USER_ACCESS_MANAGER;

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
		IAccessManagerSepolia _accessManager
	) CCIPReceiver(_router) {
		LINK_TOKEN = IERC20(_link);
		USER_LOAN_MANAGER = ILoanManagerSepolia(msg.sender);
		USER_ACCESS_MANAGER = _accessManager;
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
	 * @notice Send a collateral deposit request to another chain.
	 * @dev The contract should have sufficient LINK.
	 * @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
	 * @param _receiver The address of the recipient on the destination blockchain.
	 */
	function sendRequest(
		uint64 _destinationChainSelector,
		address _receiver,
		Request calldata _collateralDepositRequest
	) external onlyAllowlistedDestinationChain(_destinationChainSelector) {
		// Only the LoanManager contract can send messages
		if (msg.sender != address(USER_LOAN_MANAGER)) {
			revert OnlyLoanManagerCanCall(msg.sender);
		}

		// Encode the message struct into bytes
		bytes memory data = abi.encode(_collateralDepositRequest);

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
		bytes32 lastSentMessageId = router.ccipSend(
			_destinationChainSelector,
			evm2AnyMessage
		);

		// Store data
		loanData[_collateralDepositRequest.loanId]
			.lastSentMessageId = lastSentMessageId;
		loanData[_collateralDepositRequest.loanId]
			.lastAction = _collateralDepositRequest.action;

		// Emit an event with message details
		emit RequestSent(
			lastSentMessageId,
			_collateralDepositRequest.loanId,
			_collateralDepositRequest.collateralIdOrAmount,
			_destinationChainSelector,
			_collateralDepositRequest.action,
			_collateralDepositRequest.collateralType,
			_collateralDepositRequest.collateralAddress,
			_collateralDepositRequest.borrower
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
		// Decode the data into a Response struct
		Response memory response = abi.decode(any2EvmMessage.data, (Response));

		// Store data
		loanData[response.loanId].isSuccessful = response.isSuccessful;
		loanData[response.loanId].lastAction = response.action;
		loanData[response.loanId].lastReceivedMessageId = any2EvmMessage
			.messageId;

		// Emit an event with message details
		emit MessageReceived(
			any2EvmMessage.messageId,
			any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
			abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
			response.loanId,
			response.action,
			response.isSuccessful
		);
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
 