// File: contracts/Sepolia/interfaces/IMailboxSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title IMailboxSepolia Contract Interface
 * @author GhoSafe Protocol
 * @notice Interface for the MailboxSepolia contract
 * @dev This interface should be implemented by the MailboxSepolia contract.
 */
interface IMailboxSepolia {
	/**
	 * @notice Loan request struct
	 * @param amountToBorrow Amount of loan to borrow in GHO tokens.
     * @param loanDuration Duration of the loan in seconds.
	 * @param collateralAmountOrId Amount or ID of the collateral asset.
	 * @param collateralAddress Address of the collateral asset.
	 * @param borrower Address of the borrower.
	 * @param collateralChainId Chain ID of the collateral asset.
	 * @param collateralType Type of the collateral asset: 0 for ERC20, 1 for ERC721.
	 */
	struct LoanRequest {
		uint256 amountToBorrow;
        uint256 loanDuration;
		uint256 collateralAmountOrId;
		address collateralAddress;
		address borrower;
		uint64 collateralChainId;
		bool collateralType;
	}

	/**
	 * @notice Emitted when a loan request is created.
	 * @param loanRequestId ID of the loan request.
	 * @param borrower Address of the borrower.
	 * @param collateralAmountOrId Amount or ID of the collateral asset.
	 * @param collateralAddress Address of the collateral asset.
	 * @param collateralType Type of the collateral asset: 0 for ERC20, 1 for ERC721.
	 * @param collateralChainId Chain ID of the collateral asset.
	 * @param amountToBorrow Amount of loan to borrow in GHO tokens.
     * @param loanDuration Duration of the loan in seconds.
	 */
	event LoanRequestCreated(
		uint256 indexed loanRequestId,
		address indexed borrower,
		uint256 collateralAmountOrId,
		address collateralAddress,
		uint64 collateralChainId,
		bool collateralType,
		uint256 amountToBorrow,
        uint256 loanDuration
	);
    
    /// @notice No GhoSafeID Found error
    error NoGhoSafeIDFound(address caller);

	/**
	 * @notice Creates a loan request.
	 * @param _collateralAmountOrId Amount or ID of the collateral asset.
	 * @param _collateralAddress Address of the collateral asset.
	 * @param _collateralType Type of the collateral asset: 0 for ERC20, 1 for ERC721.
	 * @param _collateralChainId Chain ID of the collateral asset.
	 * @param _amountToBorrow Amount of loan to borrow in GHO tokens.
     * @param _loanDuration Duration of the loan in seconds.
	 * @return loanRequestId ID of the loan request.
	 */
	function loanRequest(
		uint256 _collateralAmountOrId,
		address _collateralAddress,
		bool _collateralType,
		uint64 _collateralChainId,
		uint256 _amountToBorrow,
        uint256 _loanDuration
	) external returns (uint256 loanRequestId);

	/**
	 * @notice Returns the loan request.
	 * @param _loanRequestId ID of the loan request.
	 * @return loanRequest Loan request struct.
	 */
	function getLoanRequest(
		uint256 _loanRequestId
	) external view returns (LoanRequest memory loanRequest);
}
