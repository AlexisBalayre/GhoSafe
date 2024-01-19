// File: contracts/Mumbai/users/LoanSafeMumbai.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { IAccessManagerMumbai } from "../interfaces/IAccessManagerMumbai.sol";
import { ILoanSafeMumbai } from "../interfaces/ILoanSafeMumbai.sol";
import { IMessengerMumbai } from "../interfaces/IMessengerMumbai.sol";
import { MessengerMumbai } from "./MessengerMumbai.sol";
import { AccessManagerMumbai } from "./AccessManagerMumbai.sol";

/**
 * @title LoanSafeMumbai Contract
 * @author GhoSafe Protocol
 * @notice Contract for safekeeping loans
 * @dev This contract should be deployed by the SafeMumbai contract.
 */
contract LoanSafeMumbai is ILoanSafeMumbai, Context, IERC721Receiver {
	using SafeERC20 for IERC20;

	/// @notice Access manager contract.
	IAccessManagerMumbai public immutable USER_ACCESS_MANAGER;

	/// @notice Messenger contract.
	IMessengerMumbai public immutable USER_MESSENGER;

	/// @notice Mapping of loan IDs to loans.
	mapping(uint256 => Loan) private loans;

	/**
	 * @notice Constructor
	 * @param _router Address of the router contract.
	 * @param _link Address of the LINK token.
	 */
	constructor(address _router, address _link) {
		USER_ACCESS_MANAGER = IAccessManagerMumbai(
			address(new AccessManagerMumbai(msg.sender))
		);
		USER_MESSENGER = IMessengerMumbai(
			address(new MessengerMumbai(_router, _link, USER_ACCESS_MANAGER))
		);
	}

	/**
	 * @notice Checks if the collateral of a loan is owned by the contract.
	 * @param _loanId ID of the loan.
	 * @return isValid True if the collateral is owned by the contract.
	 */
	function checkLoanCollateral(
		uint256 _loanId
	) external view returns (bool isValid) {
		Loan memory loan = loans[_loanId];
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
	) external {
		if (msg.sender != address(USER_MESSENGER)) {
			revert UnauthorizedAccess(msg.sender);
		}

		loans[_loanId] = Loan(
			_collateralAmountOrId,
			_collateralType,
			_collateralAddress,
			_borrower
		);
	}

	/**
	 * @notice Sends back the collateral of a loan.
	 * @param _loanId ID of the loan.
	 */
	function sendBackCollateral(uint256 _loanId) external {
		if (msg.sender != address(USER_MESSENGER)) {
			revert UnauthorizedAccess(msg.sender);
		}

		Loan memory loan = loans[_loanId];

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

	/**
	 * @notice Seizes the collateral of a loan.
	 * @param _loanId ID of the loan.
	 * @param _receiver Address of the receiver.
	 */
	function seizeCollateral(uint256 _loanId, address _receiver) external {
		if (msg.sender != address(USER_MESSENGER)) {
			revert UnauthorizedAccess(msg.sender);
		}

		Loan memory loan = loans[_loanId];

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
		override(ILoanSafeMumbai, IERC721Receiver)
		returns (bytes4)
	{
		return this.onERC721Received.selector;
	}
}
