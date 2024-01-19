// File: contracts/Sepolia/users/MailBox.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IMailboxSepolia } from "../interfaces/IMailboxSepolia.sol";
import { IGhoSafeIDSepolia } from "../interfaces/IGhoSafeIDSepolia.sol";

contract MailboxSepolia is IMailboxSepolia {
	/// @notice Loans request counter.
	uint256 public loanRequestsCounter;

	/// @notice Loans request mapping.
	mapping(uint256 => LoanRequest) public loanRequests;

	/// @notice GhoSafeID contract.
	IGhoSafeIDSepolia private immutable GHO_SAFE_ID;

	/// @notice Safe Address
	address public immutable SAFE_ADDRESS;

	/**
	 * @notice Constructor
	 * @param _ghoSafeId Address of the GhoSafeID contract.
	 */
	constructor(address _ghoSafeId) {
		GHO_SAFE_ID = IGhoSafeIDSepolia(_ghoSafeId);
		SAFE_ADDRESS = msg.sender;
	}

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
	) external returns (uint256 loanRequestId) {
        if (GHO_SAFE_ID.balanceOf(msg.sender) == 0) {
            revert NoGhoSafeIDFound(msg.sender);
        }
		loanRequestId = loanRequestsCounter++;
		loanRequests[loanRequestId] = LoanRequest(
			_amountToBorrow,
            _loanDuration,
			_collateralAmountOrId,
			_collateralAddress,
			msg.sender,
			_collateralChainId,
			_collateralType
		);
		emit LoanRequestCreated(
			loanRequestId,
			msg.sender,
			_collateralAmountOrId,
			_collateralAddress,
			_collateralChainId,
			_collateralType,
			_amountToBorrow,
            _loanDuration
		);
	}

	/**
	 * @notice Returns the loan request.
	 * @param _loanRequestId ID of the loan request.
	 * @return loanRequestData Loan request struct.
	 */
	function getLoanRequest(
		uint256 _loanRequestId
	) external view returns (LoanRequest memory loanRequestData) {
		loanRequestData = loanRequests[_loanRequestId];
	}
}
