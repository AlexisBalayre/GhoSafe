// File: contracts/Sepolia/interfaces/ILoanSafeSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title ILoanSafeSepolia Contract Interface
 * @author GhoSafe Protocol
 * @notice Interface for the LoanSafeSepolia contract
 * @dev This interface should be implemented by the LoanSafeSepolia contract.
 */
interface ILoanSafeSepolia {
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
