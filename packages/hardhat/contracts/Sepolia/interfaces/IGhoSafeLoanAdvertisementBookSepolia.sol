// File: contracts/Sepolia/interfaces/IGhoSafeLoanAdvertisementBookSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title GhoSafeLoanAdvertisementBookSepolia Interface
 * @author GhoSafe Protocol
 * @notice Interface for the GhoSafeLoanAdvertisementBookSepolia contract.
 * @dev This interface should be implemented by the GhoSafeLoanAdvertisementBookSepolia contract.
 */
interface IGhoSafeLoanAdvertisementBookSepolia {
	/**
	 * @notice Struct for storing loan advertisement data.
	 * @param timestampLastUpdate The timestamp of the last update.
	 * @param maxLoanAmount The maximum loan amount (in Gho tokens)
	 * @param maxDuration The maximum loan duration (in seconds)
	 * @param interestRate The interest rate (in basis points)
	 * @param safeAddress The address of the GhoSafe contract.
	 * @param loanManagerAddress The address of the loan manager contract.
	 * @param isAvailable The availability of the loan advertisement.
	 **/
	struct LoanAdvertisement {
		uint256 timestampLastUpdate;
		uint256 maxLoanAmount;
		uint256 maxDuration;
		uint256 interestRate;
		address safeAddress;
		address loanManagerAddress;
		bool isAvailable;
	}

	/// @notice Not authorized Caller error
	error UnauthorizedAccess(address caller);

	/**
	 * @notice Event emitted when a new loan advertisement is published.
	 * @param loanId The ID of the loan advertisement.
	 * @param maxLoanAmount The maximum loan amount (in Gho tokens)
	 * @param maxDuration The maximum loan duration (in seconds)
	 * @param interestRate The interest rate (in basis points)
	 * @param safeAddress The address of the GhoSafe contract.
	 * @param loanManagerAddress The address of the loan manager contract.
	 **/
	event LoanAdvertisementPublished(
		uint256 indexed loanId,
		uint256 maxLoanAmount,
		uint256 maxDuration,
		uint256 interestRate,
		address safeAddress,
		address loanManagerAddress
	);

	/**
	 * @notice Event emitted when a loan advertisement is updated.
	 * @param loanId The ID of the loan advertisement.
	 * @param maxLoanAmount The maximum loan amount (in Gho tokens)
	 * @param maxDuration The maximum loan duration (in seconds)
	 * @param interestRate The interest rate (in basis points)
	 * @param isAvailable The availability of the loan advertisement.
	 **/
	event LoanAdvertisementUpdated(
		uint256 indexed loanId,
		uint256 maxLoanAmount,
		uint256 maxDuration,
		uint256 interestRate,
		bool isAvailable
	);

	/**
	 * @notice Publishes a new loan advertisement.
	 * @param _maxLoanAmount The maximum loan amount in Gho tokens.
	 * @param _maxDuration The maximum loan duration in seconds.
	 * @param _interestRate The interest rate in basis points.
	 * @param _safeAddress The address of the GhoSafe contract.
	 * @param _loanManagerAddress The address of the loan manager contract.
	 * @return loanId The ID of the published loan advertisement.
	 */
	function publishLoanAdvertisement(
		uint256 _maxLoanAmount,
		uint256 _maxDuration,
		uint256 _interestRate,
		address _safeAddress,
		address _loanManagerAddress
	) external returns (uint256 loanId);

	/**
	 * @notice Updates the data of an existing loan advertisement.
	 * @param _loanId The ID of the loan advertisement.
	 * @param _maxLoanAmount The updated maximum loan amount.
	 * @param _maxDuration The updated maximum loan duration.
	 * @param _interestRate The updated interest rate.
	 * @param _isAvailable The updated availability status.
	 */
	function updateLoanAdvertisementData(
		uint256 _loanId,
		uint256 _maxLoanAmount,
		uint256 _maxDuration,
		uint256 _interestRate,
		bool _isAvailable
	) external;

	/**
	 * @notice Retrieves the data of a specific loan advertisement.
	 * @param _loanId The ID of the loan advertisement.
	 * @return loanAdvertisementData The data of the requested loan advertisement.
	 */
	function getLoanAdvertisementData(
		uint256 _loanId
	) external view returns (LoanAdvertisement memory loanAdvertisementData);
}
