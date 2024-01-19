// File: contracts/Sepolia/users/LoanSafeSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { ILoanManagerSepolia } from "../interfaces/ILoanManagerSepolia.sol";
import { ISafeSepolia } from "../interfaces/ISafeSepolia.sol";
import { ILoanSafeSepolia } from "../interfaces/ILoanSafeSepolia.sol";

/**
 * @title LoanSafeSepolia Contract
 * @author GhoSafe Protocol
 * @notice Contract for safekeeping loans
 * @dev This contract should be deployed by the SafeSepolia contract.
 */
contract LoanSafeSepolia is ILoanSafeSepolia, IERC721Receiver {
	using SafeERC20 for IERC20;

	/// @notice Loan manager contract.
	ILoanManagerSepolia public immutable USER_LOAN_MANAGER;

	/**
	 * @notice Constructor
	 */
	constructor() {
		USER_LOAN_MANAGER = ILoanManagerSepolia(msg.sender);
	}

	/**
	 * @notice Checks if the collateral of a loan is owned by the contract.
	 * @param _loanId ID of the loan.
	 * @return isValid True if the collateral is owned by the contract.
	 */
	function checkLoanCollateral(
		uint256 _loanId
	) external view returns (bool isValid) {
		ILoanManagerSepolia.Loan memory loan = USER_LOAN_MANAGER.getLoanData(
			_loanId
		);

		if (loan.isActive) {
			if (loan.collateralType == false) {
				if (
					IERC721(loan.collateralAddress).ownerOf(
						loan.collateralAmountOrId
					) == address(this)
				) {
					isValid = true;
				}
			} else {
				if (
					IERC20(loan.collateralAddress).balanceOf(address(this)) >=
					loan.collateralAmountOrId
				) {
					isValid = true;
				}
			}
		}
	}

	/**
	 * @notice Sends back the collateral of a loan.
	 * @param _loanId ID of the loan.
	 */
	function sendBackCollateral(uint256 _loanId) external {
		if (msg.sender != address(USER_LOAN_MANAGER)) {
			revert UnauthorizedAccess(msg.sender);
		}

		ILoanManagerSepolia.Loan memory loan = USER_LOAN_MANAGER.getLoanData(
			_loanId
		);

		if (loan.isActive) {
			if (loan.collateralType == false) {
				IERC721(loan.collateralAddress).safeTransferFrom(
					address(this),
					loan.borrower,
					loan.collateralAmountOrId
				);
			} else {
				IERC20(loan.collateralAddress).safeTransfer(
					loan.borrower,
					loan.collateralAmountOrId
				);
			}
		}
	}

	/**
	 * @notice Seizes the collateral of a loan.
	 * @param _loanId ID of the loan.
	 * @param _receiver Address of the receiver.
	 */
	function seizeCollateral(uint256 _loanId, address _receiver) external {
		if (msg.sender != address(USER_LOAN_MANAGER)) {
			revert UnauthorizedAccess(msg.sender);
		}

		ILoanManagerSepolia.Loan memory loan = USER_LOAN_MANAGER.getLoanData(
			_loanId
		);

		if (!loan.isActive) {
			if (loan.collateralType == false) {
				IERC721(loan.collateralAddress).safeTransferFrom(
					address(this),
					_receiver,
					loan.collateralAmountOrId
				);
			} else {
				IERC20(loan.collateralAddress).safeTransfer(
					_receiver,
					loan.collateralAmountOrId
				);
			}
		}
	}

	/**
	 * @dev The contract should be able to receive ERC721 tokens.
	 */
	function onERC721Received(
		address,
		address,
		uint256,
		bytes calldata
	)
		external
		pure
		override(ILoanSafeSepolia, IERC721Receiver)
		returns (bytes4)
	{
		return this.onERC721Received.selector;
	}
}
