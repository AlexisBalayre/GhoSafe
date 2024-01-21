// File: contracts/Sepolia/protocol/GhoSafeLoanAdvertisementBookSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IGhoSafeAccessManagerSepolia } from "../interfaces/IGhoSafeAccessManagerSepolia.sol";
import { IGhoSafeLoanAdvertisementBookSepolia } from "../interfaces/IGhoSafeLoanAdvertisementBookSepolia.sol";

/**
 * @title GhoSafeLoanAdvertisementBookSepolia Contract
 * @author GhoSafe Protocol
 * @notice Contract for publishing loan advertisements.
 */
contract GhoSafeLoanAdvertisementBookSepolia is
	IGhoSafeLoanAdvertisementBookSepolia
{
	/// @dev Access manager contract.
	IGhoSafeAccessManagerSepolia internal immutable ACCESS_MANAGER;

	/// @dev Mapping from loanId to loan advertisement data.
	mapping(uint256 => LoanAdvertisement) private loanAdvertisements;

	/// @dev Counter for loan advertisements.
	uint256 private loanAdvertisementsCount;

	/**
	 * @notice Initializes the contract.
	 * @param _accessManager The address of the access manager contract.
	 */
	constructor(IGhoSafeAccessManagerSepolia _accessManager) {
		ACCESS_MANAGER = _accessManager;
	}

	/**
	 * @notice Retrieves the loan advertisement data of a specific loan advertisement.
	 * @param _loanId The ID of the loan advertisement.
	 * @return loanAdvertisementData The loan advertisement data.
	 **/
	function getLoanAdvertisementData(
		uint256 _loanId
	) external view returns (LoanAdvertisement memory loanAdvertisementData) {
		loanAdvertisementData = loanAdvertisements[_loanId];
	}

	/**
	 * @notice Function to publish a new loan advertisement
	 * @param _maxLoanAmount The maximum loan amount (in Gho tokens)
	 * @param _maxDuration The maximum loan duration (in seconds)
	 * @param _interestRate The interest rate (in basis points)
	 * @param _safeAddress The address of the GhoSafe contract.
	 * @param _loanManagerAddress The address of the loan manager contract.
	 * @return loanId The ID of the loan advertisement.
	 **/
	function publishLoanAdvertisement(
		uint256 _maxLoanAmount,
		uint256 _maxDuration,
		uint256 _interestRate,
		address _safeAddress,
		address _loanManagerAddress
	) external returns (uint256 loanId) {
		if (
			!ACCESS_MANAGER.hasRole(
				keccak256("LOAN_PUBLISHER_ROLE"),
				msg.sender
			)
		) {
			revert UnauthorizedAccess(msg.sender);
		}

		loanId = ++loanAdvertisementsCount;

		loanAdvertisements[loanId] = LoanAdvertisement({
			timestampLastUpdate: block.timestamp,
			maxLoanAmount: _maxLoanAmount,
			maxDuration: _maxDuration,
			interestRate: _interestRate,
			safeAddress: _safeAddress,
			loanManagerAddress: _loanManagerAddress,
			isAvailable: true
		});

		emit LoanAdvertisementPublished(
			loanId,
			_maxLoanAmount,
			_maxDuration,
			_interestRate,
			_safeAddress,
			_loanManagerAddress
		);
	}

	/**
	 * @notice Function to update the availability of a loan advertisement
	 * @param _loanId The ID of the loan advertisement.
	 * @param _maxLoanAmount The maximum loan amount (in Gho tokens)
	 * @param _maxDuration The maximum loan duration (in seconds)
	 * @param _interestRate The interest rate (in basis points)
	 * @param _isAvailable The availability of the loan advertisement.
	 **/
	function updateLoanAdvertisementData(
		uint256 _loanId,
		uint256 _maxLoanAmount,
		uint256 _maxDuration,
		uint256 _interestRate,
		bool _isAvailable
	) external {
		if (msg.sender != loanAdvertisements[_loanId].loanManagerAddress) {
			revert UnauthorizedAccess(msg.sender);
		}

		loanAdvertisements[_loanId].timestampLastUpdate = block.timestamp;
		loanAdvertisements[_loanId].maxLoanAmount = _maxLoanAmount;
		loanAdvertisements[_loanId].maxDuration = _maxDuration;
		loanAdvertisements[_loanId].interestRate = _interestRate;
		loanAdvertisements[_loanId].isAvailable = _isAvailable;

		emit LoanAdvertisementUpdated(
			_loanId,
			_maxLoanAmount,
			_maxDuration,
			_interestRate,
			_isAvailable
		);
	}
}
