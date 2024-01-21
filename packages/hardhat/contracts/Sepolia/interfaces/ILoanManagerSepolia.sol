// File: contracts/Sepolia/interfaces/ILoanManagerSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IGhoSafeLoanAdvertisementBookSepolia } from "../interfaces/IGhoSafeLoanAdvertisementBookSepolia.sol";

/**
 * @title ILoanManagerSepolia Contract Interface
 * @author GhoSafe Protocol
 * @notice Interface for the LoanManagerSepolia contract
 * @dev This interface should be implemented by the LoanManagerSepolia contract.
 */
interface ILoanManagerSepolia {
	/**
	 * @notice Loan struct
	 * @param loanId ID of the loan.
	 * @param loanRequestId ID of the loan request.
	 * @param startTimestamp Timestamp when the loan was started.
	 * @param duration Duration of the loan in seconds.
	 * @param interestRate Interest rate for the loan in basis points (BPS).
	 * @param loanAmount Amount of loan.
	 * @param collateralAmountOrId Amount or ID of the collateral asset.
	 * @param collateralChainId Chain ID of the collateral asset.
	 * @param collateralAddress Address of the collateral asset.
	 * @param collateralType Type of collateral (ERC20 or ERC721).
	 * @param borrower Address of the borrower.
	 */
	struct Loan {
		uint256 loanId;
		uint256 loanRequestId;
		uint256 startTimestamp;
		uint256 duration;
		uint256 interestRate;
		uint256 loanAmount;
		uint256 collateralAmountOrId;
		uint64 collateralChainId;
		address collateralAddress;
		bool collateralType;
		address borrower;
		bool isActive;
	}

	/**
	 * @notice Emitted when loan parameters are updated.
	 * @param maxLoanDuration The maximum duration of a loan in seconds.
	 * @param availableBorrowPowerPercent Percentage of total borrow power that is available for borrowing.
	 * @param maxLoanAmountPercentPerBorrower Maximum loan amount per borrower as a percentage of available borrow power.
	 */
	event LoanParametersUpdated(
		uint256 maxLoanDuration,
		uint256 availableBorrowPowerPercent,
		uint256 maxLoanAmountPercentPerBorrower
	);

	/**
	 * @notice Emitted when a loan advertisement is published.
	 * @param loanAdvertisementId ID of the loan advertisement.
	 * @param maxLoanDuration The maximum duration of a loan in seconds.
	 * @param maxLoanAmount Maximum loan amount.
	 * @param interestRate Interest rate for the loan in basis points (BPS).
	 */
	event LoanAdvertisementPublished(
		uint256 loanAdvertisementId,
		uint256 maxLoanDuration,
		uint256 maxLoanAmount,
		uint256 interestRate
	);

	/**
	 * @notice Emitted when a loan advertisement is updated.
	 * @param loanAdvertisementId ID of the loan advertisement.
	 * @param isAvailable Whether the loan advertisement is available.
	 * @param maxLoanDuration The maximum duration of a loan in seconds.
	 * @param maxLoanAmount Maximum loan amount.
	 * @param interestRate Interest rate for the loan in basis points (BPS).
	 */
	event LoanAdvertisementUpdated(
		uint256 loanAdvertisementId,
		bool isAvailable,
		uint256 maxLoanDuration,
		uint256 maxLoanAmount,
		uint256 interestRate
	);

	/**
	 * @notice Emitted when a loan request is authorized.
	 * @param loanRequestId ID of the loan request.
	 * @param loanId ID of the loan.
	 * @param borrower Address of the borrower.
	 * @param duration Duration of the loan in seconds.
	 * @param interestRate Interest rate for the loan in basis points (BPS).
	 * @param loanAmount Amount of loan.
	 * @param collateralChainId Chain ID of the collateral asset.
	 * @param collateralAddress Address of the collateral asset.
	 * @param collateralAmountOrId Amount or ID of the collateral asset.
	 * @param collateralType Type of collateral (ERC20 or ERC721).
	 */
	event LoanRequestAuthorized(
		uint256 indexed loanRequestId,
		uint256 indexed loanId,
		address indexed borrower,
		uint256 duration,
		uint256 interestRate,
		uint256 loanAmount,
		uint64 collateralChainId,
		address collateralAddress,
		uint256 collateralAmountOrId,
		bool collateralType
	);

	/**
	 * @notice Emitted when a loan is borrowed.
	 * @param loanId ID of the loan.
	 * @param borrower Address of the borrower.
	 * @param duration Duration of the loan in seconds.
	 * @param interestRate Interest rate for the loan in basis points (BPS).
	 * @param loanAmount Amount of loan.
	 * @param collateralChainId Chain ID of the collateral asset.
	 * @param collateralAddress Address of the collateral asset.
	 * @param collateralAmountOrId Amount or ID of the collateral asset.
	 * @param collateralType Type of collateral (ERC20 or ERC721).
	 */
	event LoanBorrowed(
		uint256 indexed loanId,
		address indexed borrower,
		uint256 duration,
		uint256 interestRate,
		uint256 loanAmount,
		uint64 collateralChainId,
		address collateralAddress,
		uint256 collateralAmountOrId,
		bool collateralType
	);

	/**
	 * @notice Emitted when a loan is repaid.
	 * @param loanId ID of the loan.
	 * @param borrower Address of the borrower.
	 * @param loanAmount Amount of loan.
	 * @param interestAmount Amount of interest.
	 */
	event LoanRepaid(
		uint256 indexed loanId,
		address indexed borrower,
		uint256 loanAmount,
		uint256 interestAmount
	);

	/**
	 * @notice Emitted when a loan is liquidated.
	 * @param loanId ID of the loan.
	 * @param borrower Address of the borrower.
	 * @param liquidator Address of the liquidator.
	 * @param loanAmount Amount of loan.
	 * @param interestAmount Amount of interest.
	 */
	event LoanLiquidated(
		uint256 indexed loanId,
		address indexed borrower,
		address indexed liquidator,
		uint256 loanAmount,
		uint256 interestAmount
	);

	event CrosschainLoanBorrowedInit(
		uint256 indexed loanId,
		address indexed borrower,
		uint256 duration,
		uint256 interestRate,
		uint256 loanAmount,
		uint64 collateralChainId,
		address collateralAddress,
		uint256 collateralAmountOrId,
		bool collateralType
	);

	/**
	 * @notice Emitted when a loan is started.
	 * @param loanId ID of the loan.
	 * @param startTimestamp Timestamp when the loan was started.
	 */
	event LoanStarted(uint256 indexed loanId, uint256 startTimestamp);

	/// @notice Emitted when a loan advertisement is published.
	error UnauthorizedAccess(address caller);

	/// @notice Loan already borrowed error.
	error LoanAlreadyBorrowed(uint256 loanId);

	/// @notice Loan not active error.
	error LoanNotActive(uint256 loanId);

	/// @notice Wrong Borrower error.
	error WrongBorrower(address caller, address borrower);

	/// @notice Loan Still Active error.
	error LoanStillActive(uint256 loanId);

	/// @notice Only owner can call error.
	error OnlyOwnerCanCall(address sender);

	/// @notice Collateral Not Deposited error.
	error CollateralNotDeposited(uint256 loanId);

	/**
	 * @notice Sets the loan parameters.
	 * @param _maxLoanDuration The maximum duration of a loan in seconds.
	 * @param _availableBorrowPowerPercent Percentage of total borrow power that is available for borrowing.
	 * @param _maxLoanAmountPercentPerBorrower Maximum loan amount per borrower as a percentage of available borrow power.
	 * @param _interestRate Interest rate for loans in basis points (BPS)
	 */
	function setLoanParameters(
		uint256 _maxLoanDuration,
		uint256 _availableBorrowPowerPercent,
		uint256 _maxLoanAmountPercentPerBorrower,
		uint256 _interestRate
	) external;

	/**
	 * @notice Returns the available borrow power.
	 * @return availableBorrowPower The available borrow power.
	 */
	function getAvailableBorrowPower()
		external
		view
		returns (uint256 availableBorrowPower);

	/**
	 * @notice Returns the maximum loan amount per borrower.
	 * @return maxLoanAmountPerBorrower The maximum loan amount per borrower (in GHO tokens)
	 */
	function getMaxLoanAmountPerBorrower()
		external
		view
		returns (uint256 maxLoanAmountPerBorrower);

	/**
	 * @notice Returns the number of loan advertisements.
	 * @return loanAdvertisementsCount The number of loan advertisements.
	 */
	function getLoanAdvertisementsCount() external view returns (uint256);

	/**
	 * @notice Returns the loan advertisement ID at the specified index.
	 * @param index The index of the loan advertisement ID.
	 * @return loanAdvertisementId The loan advertisement ID.
	 */
	function getLoanAdvertisementId(
		uint256 index
	) external view returns (uint256);

	/**
	 * @notice Returns the loan advertisement IDs.
	 * @return loanIds The loan advertisement IDs.
	 */
	function getLoanAdvertisementIds() external view returns (uint256[] memory);

	/**
	 * @notice Returns the loan advertisement data.
	 * @param _loanId The loan advertisement ID.
	 * @return loanAdvertisementData The loan advertisement data.
	 */
	function getLoanAdvertisementData(
		uint256 _loanId
	)
		external
		view
		returns (
			IGhoSafeLoanAdvertisementBookSepolia.LoanAdvertisement
				memory loanAdvertisementData
		);

	/**
	 * @notice Returns the loan data.
	 * @param _loanId The loan ID.
	 * @return loan The loan data.
	 */
	function getLoanData(
		uint256 _loanId
	) external view returns (Loan memory loan);

	/**
	 * @notice Publishes a loan advertisement.
	 */
	function publishLoanAdvertisement() external;

	/**
	 * @notice Updates the loan advertisement data.
	 * @param _loanId The loan advertisement ID.
	 * @param _isAvailable Whether the loan advertisement is available.
	 */
	function updateLoanAdvertisementData(
		uint256 _loanId,
		bool _isAvailable
	) external;

	/**
	 * @notice Returns whether a loan request is already authorized.
	 * @param _loanRequestId ID of the loan request.
	 * @return isAlreadyAuthorized Whether the loan request is already authorized.
	 */
	function isRequestAlreadyAuthorized(
		uint256 _loanRequestId
	) external view returns (bool isAlreadyAuthorized);

	/**
	 * @notice Authorizes a loan request.
	 * @param _loanRequestId ID of the loan request.
	 */
	function authorizeLoan(uint256 _loanRequestId) external;

	/**
	 * @notice Starts a loan.
	 * @param _loanId ID of the loan.
	 */
	function borrow(uint256 _loanId) external;
}
