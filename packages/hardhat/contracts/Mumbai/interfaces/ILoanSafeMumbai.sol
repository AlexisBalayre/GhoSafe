// File: contracts/Mumbai/interfaces/ILoanSafeMumbai.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title ILoanSafeMumbai Contract Interface
 * @author GhoSafe Protocol
 * @notice Interface for the LoanSafeMumbai contract
 * @dev This interface should be implemented by the LoanSafeMumbai contract.
 */
interface ILoanSafeMumbai {
	struct Loan {
		uint256 collateralAmountOrId;
		bool collateralType;
		address collateralAddress;
		address borrower;
	}
	
	/// @notice Unauthorized access error.
	error UnauthorizedAccess(address caller);

	/**
	 * @notice Emitted when a loan is started.
	 * @param loanId ID of the loan.
	 * @param startTimestamp Timestamp when the loan was started.
	 */
	event LoanStarted(uint256 indexed loanId, uint256 startTimestamp);

	/**
	 * @notice Checks if the collateral of a loan is owned by the contract.
	 * @param _loanId ID of the loan.
	 * @return isValid True if the collateral is owned by the contract.
	 */
	function checkLoanCollateral(
		uint256 _loanId
	) external view returns (bool isValid);

	/**
	 * @notice Sets the loan data.
	 * @param _loanId ID of the loan.
	 * @param _collateralAmountOrId Amount or ID of the collateral.
	 * @param _collateralType Type of the collateral.
	 * @param _collateralAddress Address of the collateral.
	 * @param _borrower Address of the borrower.
	 */
	function setLoanData(
		uint256 _loanId,
		uint256 _collateralAmountOrId,
		bool _collateralType,
		address _collateralAddress,
		address _borrower
	) external;

	/**
	 * @notice Sends back the collateral of a loan.
	 * @param _loanId ID of the loan.
	 */
	function sendBackCollateral(uint256 _loanId) external;

	/**
	 * @notice Seizes the collateral of a loan.
	 * @param _loanId ID of the loan.
	 * @param _receiver Address of the receiver.
	 */
	function seizeCollateral(uint256 _loanId, address _receiver) external;

	/**
	 * @dev The contract should be able to receive ERC721 tokens.
	 */
	function onERC721Received(
		address,
		address,
		uint256,
		bytes calldata
	) external pure returns (bytes4);
}
