// File: contracts/Mumbai/interfaces/IMessengerMumbai.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title IMessengerMumbai Contract Interface
 * @author GhoSafe Protocol
 * @notice Interface for the MessengerMumbai contract
 * @dev This interface should be implemented by the MessengerMumbai contract.
 */
interface IMessengerMumbai {
	/**
	 * @notice Struct for loan data
	 * @param messageId Message ID
	 * @param loanId ID of the loan
	 * @param collateralIdOrAmount Collateral ID or amount
	 * @param collateralChainId Collateral chain ID
	 * @param action Action
	 * @param collateralType Collateral type
	 * @param collateralAddress Collateral address
	 * @param borrower Borrower address
	 */
	struct LoanData {
		bytes32 lastReceivedMessageId;
		bytes32 lastSentMessageId;
		uint8 lastAction;
		bool isSuccessful;
	}

	/**
	 * @notice Struct for request
	 * @param loanId ID of the loan
	 * @param collateralIdOrAmount Collateral ID or amount
	 * @param action Action
	 * @param collateralType Collateral type
	 * @param collateralAddress Collateral address
	 * @param borrower Borrower address
	 */
	struct Request {
		uint256 loanId;
		uint256 collateralIdOrAmount;
		uint8 action;
		bool collateralType;
		address collateralAddress;
		address borrower;
	}

	/**
	 * @notice Struct for response
	 * @param loanId ID of the loan
	 * @param action Action
	 * @param isSuccessful True if the response is successful
	 */
	struct Response {
		uint256 loanId;
		uint8 action;
		bool isSuccessful;
	}

	/// @notice Not enough balance error.
	error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);

	/// @notice Nothing to withdraw error.
	error NothingToWithdraw();

	/// @notice Destination chain not allowlisted error.
	error DestinationChainNotAllowlisted(uint64 destinationChainSelector);

	/// @notice Source chain not allowlisted error.
	error SourceChainNotAllowlisted(uint64 sourceChainSelector);

	/// @notice Sender not allowlisted error.
	error SenderNotAllowlisted(address sender);

	/// @notice Only owner can call error.
	error OnlyOwnerCanCall(address sender);

	/// @notice Only loan manager can call error.
	error OnlyLoanManagerCanCall(address sender);

	/**
	 * @notice Emitted when a Deposit Request is sent.
	 * @param messageId ID of the message.
	 * @param loanId ID of the loan.
	 * @param collateralIdOrAmount Collateral ID or amount.
	 * @param collateralChainId Collateral chain ID.
	 * @param action Action.
	 * @param collateralType Collateral type.
	 * @param collateralAddress Collateral address.
	 * @param borrower Borrower address.
	 */
	event RequestSent(
		bytes32 indexed messageId,
		uint256 indexed loanId,
		uint256 collateralIdOrAmount,
		uint64 collateralChainId,
		uint8 action,
		bool collateralType,
		address collateralAddress,
		address borrower
	);

	/**
	 * @notice Emitted when a Message is received.
	 * @param messageId ID of the message.
	 * @param sourceChainSelector Source chain ID.
	 * @param sender Sender address.
	 * @param loanId ID of the loan.
	 * @param action Action.
	 * @param isSuccessful True if the response is successful.
	 */
	event MessageReceived(
		bytes32 indexed messageId, // The unique ID of the CCIP message.
		uint64 indexed sourceChainSelector, // The chain selector of the source chain.
		address sender, // The address of the sender from the source chain.
		uint256 loanId, // The ID of the loan.
		uint8 action, // The action of the message.
		bool isSuccessful // The success status of the message.
	);

	/**
	 * @notice Allows the contract owner to update the allowlist status of a destination chain for transactions.
	 * @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
	 * @param _allowed The new allowlist status.
	 * @dev This function reverts if the sender is not the owner.
	 */
	function allowlistDestinationChain(
		uint64 _destinationChainSelector,
		bool _allowed
	) external;

	/**
	 * @notice Returns the loan data for a given loan ID.
	 * @param _loanId ID of the loan.
	 * @return LoanData Loan data.
	 */
	function getLoanData(
		uint256 _loanId
	) external view returns (LoanData memory);

	/**
	 * @notice Allows the contract owner to update the allowlist status of a source chain for transactions.
	 * @param _sourceChainSelector The identifier (aka selector) for the source blockchain.
	 * @param _allowed The new allowlist status.
	 * @dev This function reverts if the sender is not the owner.
	 */
	function allowlistSourceChain(
		uint64 _sourceChainSelector,
		bool _allowed
	) external;

	/**
	 * @notice Allows the contract owner to update the allowlist status of a sender for transactions.
	 * @param _sender The address of the sender.
	 * @param _allowed The new allowlist status.
	 * @dev This function reverts if the sender is not the owner.
	 */
	function allowlistSender(address _sender, bool _allowed) external;

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
	) external;
}
