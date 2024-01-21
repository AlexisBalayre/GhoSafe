// File: contracts/Sepolia/users/LoanManagerSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { IAccessManagerSepolia } from "../interfaces/IAccessManagerSepolia.sol";
import { IGhoSafeLoanAdvertisementBookSepolia } from "../interfaces/IGhoSafeLoanAdvertisementBookSepolia.sol";
import { ILoanManagerSepolia } from "../interfaces/ILoanManagerSepolia.sol";
import { ILoanSafeSepolia } from "../interfaces/ILoanSafeSepolia.sol";
import { IMailboxSepolia } from "../interfaces/IMailboxSepolia.sol";
import { ISafeSepolia } from "../interfaces/ISafeSepolia.sol";
import { IMessengerSepolia } from "../interfaces/IMessengerSepolia.sol";
import { LoanSafeSepolia } from "./LoanSafeSepolia.sol";
import { MessengerSepolia } from "./MessengerSepolia.sol";

/**
 * @title LoanManagerSepolia Contract
 * @author GhoSafe Protocol
 * @notice Contract for managing loans
 * @dev This contract should be deployed by the SafeSepolia contract.
 */
contract LoanManagerSepolia is ILoanManagerSepolia, ReentrancyGuard {
	using EnumerableSet for EnumerableSet.UintSet;
	using SafeERC20 for IERC20;

	/// @notice The maximum duration of a loan in seconds.
	uint256 public maxLoanDuration;

	/// @notice Percentage of total borrow power that is available for borrowing.
	uint256 public availableBorrowPowerPercent;

	/// @notice Maximum loan amount per borrower as a percentage of available borrow power.
	uint256 public maxLoanAmountPercentPerBorrower;

	/// @notice Interest rate for loans in basis points (BPS)
	uint256 public interestRate;

	/// @notice Safe contract.
	ISafeSepolia public immutable USER_SAFE;

	/// @notice Access manager contract.
	IAccessManagerSepolia public immutable USER_ACCESS_MANAGER;

	/// @notice Mailbox contract.
	IMailboxSepolia public immutable USER_MAILBOX;

	/// @notice Loan Safe contract.
	ILoanSafeSepolia public immutable USER_LOAN_SAFE;

	/// @notice Messenger contract.
	IMessengerSepolia public immutable USER_MESSENGER;

	/// @dev Loan advertisement book contract.
	IGhoSafeLoanAdvertisementBookSepolia
		public immutable LOAN_ADVERTISEMENT_BOOK;

	/// @dev Debt Gho token contract: https://sepolia.etherscan.io/address/0x67ae46EF043F7A4508BD1d6B94DB6c33F0915844
	IERC20 private immutable DEBT_GHO_TOKEN;

	/// @dev Gho token contract: https://sepolia.etherscan.io/address/0xc4bF5CbDaBE595361438F8c6a187bDc330539c60
	IERC20 internal immutable GHO_TOKEN;

	/// @dev Set of loan advertisement IDs.
	EnumerableSet.UintSet private _loanAdvertisementIds;

	/// @notice Loans mapping.
	mapping(uint256 => Loan) private loans;

	/// @notice Messengers mapping (chain ID => address)
	mapping(uint64 => address) public messengers;

	/// @dev Loans counter.
	uint256 private _loanCounter;

	/**
	 * @notice Constructor
	 * @param _accessManager Address of the access manager contract.
	 * @param _mailbox Address of the mailbox contract.
	 * @param _loanAdvertisementBook Address of the loan advertisement book contract.
	 * @param _ghoToken Address of the GHO token.
	 * @param _debtGhoToken Address of the debt GHO token.
	 * @param _router Address of the router contract.
	 * @param _link Address of the LINK token.
	 */
	constructor(
		IAccessManagerSepolia _accessManager,
		address _mailbox,
		address _loanAdvertisementBook,
		address _ghoToken,
		address _debtGhoToken,
		address _router,
		address _link
	) {
		GHO_TOKEN = IERC20(_ghoToken);
		DEBT_GHO_TOKEN = IERC20(_debtGhoToken);
		USER_SAFE = ISafeSepolia(payable(msg.sender));
		USER_ACCESS_MANAGER = _accessManager;
		USER_MAILBOX = IMailboxSepolia(_mailbox);
		LOAN_ADVERTISEMENT_BOOK = IGhoSafeLoanAdvertisementBookSepolia(
			_loanAdvertisementBook
		);
		USER_LOAN_SAFE = ILoanSafeSepolia(address(new LoanSafeSepolia()));
		USER_MESSENGER = IMessengerSepolia(
			address(new MessengerSepolia(_router, _link, _accessManager))
		);
	}

	modifier onlyOwner() {
		if (!USER_ACCESS_MANAGER.hasRole(keccak256("OWNER_ROLE"), msg.sender)) {
			revert OnlyOwnerCanCall(msg.sender);
		}
		_;
	}

	/**
	 * @notice Returns the available borrow power.
	 * @return availableBorrowPower The available borrow power.
	 */
	function getAvailableBorrowPower()
		public
		view
		returns (uint256 availableBorrowPower)
	{
		uint256 totalBorrowPower = DEBT_GHO_TOKEN.balanceOf(address(USER_SAFE));
		availableBorrowPower =
			(totalBorrowPower * availableBorrowPowerPercent) /
			100;
	}

	/**
	 * @notice Returns the maximum loan amount per borrower.
	 * @return maxLoanAmountPerBorrower The maximum loan amount per borrower (in GHO tokens)
	 */
	function getMaxLoanAmountPerBorrower()
		public
		view
		returns (uint256 maxLoanAmountPerBorrower)
	{
		uint256 totalBorrowPower = DEBT_GHO_TOKEN.balanceOf(address(USER_SAFE));
		uint256 availableBorrowPower = (totalBorrowPower *
			availableBorrowPowerPercent) / 100;
		maxLoanAmountPerBorrower =
			(availableBorrowPower * maxLoanAmountPercentPerBorrower) /
			100;
	}

	/**
	 * @notice Returns the number of loan advertisements.
	 * @return loanAdvertisementsCount The number of loan advertisements.
	 */
	function getLoanAdvertisementsCount() external view returns (uint256) {
		return _loanAdvertisementIds.length();
	}

	/**
	 * @notice Returns the loan advertisement ID at the specified index.
	 * @param index The index of the loan advertisement ID.
	 * @return loanAdvertisementId The loan advertisement ID.
	 */
	function getLoanAdvertisementId(
		uint256 index
	) external view returns (uint256) {
		return _loanAdvertisementIds.at(index);
	}

	/**
	 * @notice Returns the loan advertisement IDs.
	 * @return loanIds The loan advertisement IDs.
	 */
	function getLoanAdvertisementIds()
		external
		view
		returns (uint256[] memory)
	{
		uint256[] memory loanIds = new uint256[](
			_loanAdvertisementIds.length()
		);
		for (uint256 i = 0; i < _loanAdvertisementIds.length(); i++) {
			loanIds[i] = _loanAdvertisementIds.at(i);
		}
		return loanIds;
	}

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
		)
	{
		loanAdvertisementData = LOAN_ADVERTISEMENT_BOOK
			.getLoanAdvertisementData(_loanId);
	}

	/**
	 * @notice Returns the loan data.
	 * @param _loanId The loan ID.
	 * @return loan The loan data.
	 */
	function getLoanData(
		uint256 _loanId
	) external view returns (Loan memory loan) {
		loan = loans[_loanId];
	}

	/**
	 * @notice Returns the total interest and the loan amount with interest.
	 * @param _loanId The loan ID.
	 * @return totalInterest The total interest for the loan.
	 * @return loanAmountWithInterest The loan amount with interest.
	 */
	function getTotalInterest(
		uint256 _loanId
	)
		external
		view
		returns (uint256 totalInterest, uint256 loanAmountWithInterest)
	{
		Loan memory loan = loans[_loanId];
		totalInterest = (loan.loanAmount * loan.interestRate) / 10000;
		loanAmountWithInterest = loan.loanAmount + totalInterest;
	}

	/**
	 * @notice Returns the remaining loan time.
	 * @param _loanId The loan ID.
	 * @return remainingLoanTime The remaining loan time.
	 */
	function getRemainingLoanTime(
		uint256 _loanId
	) external view returns (uint256 remainingLoanTime) {
		Loan memory loan = loans[_loanId];
		remainingLoanTime =
			loan.startTimestamp +
			loan.duration -
			block.timestamp;
	}

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
	) external onlyOwner {
		maxLoanDuration = _maxLoanDuration;
		availableBorrowPowerPercent = _availableBorrowPowerPercent;
		maxLoanAmountPercentPerBorrower = _maxLoanAmountPercentPerBorrower;
		interestRate = _interestRate;
		emit LoanParametersUpdated(
			_maxLoanDuration,
			_availableBorrowPowerPercent,
			_maxLoanAmountPercentPerBorrower
		);
	}

	/**
	 * @notice Sets the messenger address for a chain ID.
	 * @param _chainId Chain ID.
	 * @param _messengerAddress Address of the messenger contract.
	 */
	function setMessengerAddress(
		uint64 _chainId,
		address _messengerAddress
	) external onlyOwner {
		messengers[_chainId] = _messengerAddress;
	}

	/**
	 * @notice Publishes a loan advertisement.
	 */
	function publishLoanAdvertisement() external onlyOwner {
		uint256 maxLoanAmountPerBorrower = getMaxLoanAmountPerBorrower();

		uint256 loanAdvertisementId = LOAN_ADVERTISEMENT_BOOK
			.publishLoanAdvertisement(
				maxLoanAmountPerBorrower,
				maxLoanDuration,
				interestRate,
				address(USER_SAFE),
				address(this)
			);

		_loanAdvertisementIds.add(loanAdvertisementId);

		emit LoanAdvertisementPublished(
			loanAdvertisementId,
			maxLoanDuration,
			maxLoanAmountPerBorrower,
			interestRate
		);
	}

	/**
	 * @notice Updates the loan advertisement data.
	 * @param _loanAdvertisementId The loan advertisement ID.
	 * @param _isAvailable Whether the loan advertisement is available.
	 */
	function updateLoanAdvertisementData(
		uint256 _loanAdvertisementId,
		bool _isAvailable
	) external onlyOwner {
		uint256 maxLoanAmountPerBorrower = getMaxLoanAmountPerBorrower();

		LOAN_ADVERTISEMENT_BOOK.updateLoanAdvertisementData(
			_loanAdvertisementId,
			maxLoanAmountPerBorrower,
			maxLoanDuration,
			interestRate,
			_isAvailable
		);

		emit LoanAdvertisementUpdated(
			_loanAdvertisementId,
			_isAvailable,
			maxLoanDuration,
			maxLoanAmountPerBorrower,
			interestRate
		);
	}

	/**
	 * @notice Returns whether a loan request is already authorized.
	 * @param _loanRequestId ID of the loan request.
	 * @return isAlreadyAuthorized Whether the loan request is already authorized.
	 */
	function isRequestAlreadyAuthorized(
		uint256 _loanRequestId
	) external view returns (bool isAlreadyAuthorized) {
		for (uint256 i = 0; i < _loanCounter; i++) {
			Loan storage loan = loans[i];
			if (loan.loanRequestId == _loanRequestId) {
				isAlreadyAuthorized = true;
				break;
			}
		}
	}

	/**
	 * @notice Authorizes a loan request.
	 * @param _loanRequestId ID of the loan request.
	 */
	function authorizeLoan(uint256 _loanRequestId) external onlyOwner {
		IMailboxSepolia.LoanRequest memory loanRequest = USER_MAILBOX
			.getLoanRequest(_loanRequestId);

		uint256 loanId = _loanCounter++;

		loans[loanId] = Loan(
			loanId,
			_loanRequestId,
			0,
			loanRequest.loanDuration,
			interestRate,
			loanRequest.amountToBorrow,
			loanRequest.collateralAmountOrId,
			loanRequest.collateralChainId,
			loanRequest.collateralAddress,
			loanRequest.collateralType,
			loanRequest.borrower,
			false
		);

		emit LoanRequestAuthorized(
			_loanRequestId,
			loanId,
			loanRequest.borrower,
			loanRequest.loanDuration,
			interestRate,
			loanRequest.amountToBorrow,
			loanRequest.collateralChainId,
			loanRequest.collateralAddress,
			loanRequest.collateralAmountOrId,
			loanRequest.collateralType
		);
	}

	/**
	 * @notice Initializes a loan with crosschain collateral. This function should be called by the borrower before calling `borrowWhithCrosschainCollateral`.
	 * @notice The borrower should approve the collateral amount to be transferred by the safe contract on the collateral chain before calling this function.
	 * @param _loanId ID of the loan.
	 */
	function initBorrowWhithCrosschainCollateral(
		uint256 _loanId
	) external nonReentrant {
		// Verify that the loan is not active.
		Loan memory loan = loans[_loanId];
		if (loan.startTimestamp != 0) {
			revert LoanAlreadyBorrowed(_loanId);
		}
		if (loan.borrower != msg.sender) {
			revert WrongBorrower(msg.sender, loan.borrower);
		}

		// Initialize the loan.
		USER_MESSENGER.sendRequest(
			loan.collateralChainId,
			messengers[loan.collateralChainId],
			IMessengerSepolia.Request({
				loanId: _loanId,
				collateralIdOrAmount: loan.collateralAmountOrId,
				action: 0,
				collateralType: loan.collateralType,
				collateralAddress: loan.collateralAddress,
				borrower: loan.borrower
			})
		);

		emit CrosschainLoanBorrowedInit(
			_loanId,
			loan.borrower,
			loan.duration,
			loan.interestRate,
			loan.loanAmount,
			loan.collateralChainId,
			loan.collateralAddress,
			loan.collateralAmountOrId,
			loan.collateralType
		);
	}

	/**
	 * @notice Starts a loan with crosschain collateral. This function should be called by the borrower after calling `initBorrowWhithCrosschainCollateral`.
	 * @param _loanId ID of the loan.
	 */
	function borrowWhithCrosschainCollateral(
		uint256 _loanId
	) external nonReentrant {
		// Verify that the loan is not active.
		Loan storage loan = loans[_loanId];
		if (loan.startTimestamp != 0) {
			revert LoanAlreadyBorrowed(_loanId);
		}
		if (loan.borrower != msg.sender) {
			revert WrongBorrower(msg.sender, loan.borrower);
		}

		// Verify if the collateral has been deposited.
		IMessengerSepolia.LoanData memory loanData = USER_MESSENGER.getLoanData(
			_loanId
		);
		if (loanData.lastAction == 0 && loanData.isSuccessful == false) {
			revert CollateralNotDeposited(_loanId);
		}

		// Approve loan amount to be transferred to borrower.
		USER_SAFE.approveDelegateCreditGho(loan.borrower, loan.loanAmount);

		// Update loan start timestamp.
		loan.startTimestamp = block.timestamp;
		loan.isActive = true;

		emit LoanStarted(_loanId, block.timestamp);
	}

	/**
	 * @notice Repays a loan with crosschain collateral.
	 * @param _loanId ID of the loan.
	 */
	function repayLoanCrosschainCollateral(
		uint256 _loanId
	) external nonReentrant {
		Loan storage loan = loans[_loanId];

		// Verify that the loan is active.
		if (!loan.isActive) {
			revert LoanNotActive(_loanId);
		}

		// Verify that the borrower is the one repaying the loan.
		if (loan.borrower != msg.sender) {
			revert WrongBorrower(msg.sender, loan.borrower);
		}

		// Total interest to be paid.
		uint256 totalInterest = (loan.loanAmount * loan.interestRate) / 10000;

		// Total amount to be repaid (loan amount + interest)
		uint256 totalAmountToRepay = loan.loanAmount + totalInterest;

		// Transfer GHO tokens from borrower to safe.
		GHO_TOKEN.safeTransferFrom(
			msg.sender,
			address(USER_SAFE),
			totalAmountToRepay
		);

		// Transfer collateral back to borrower.
		USER_MESSENGER.sendRequest(
			loan.collateralChainId,
			messengers[loan.collateralChainId],
			IMessengerSepolia.Request({
				loanId: _loanId,
				collateralIdOrAmount: loan.collateralAmountOrId,
				action: 1,
				collateralType: loan.collateralType,
				collateralAddress: loan.collateralAddress,
				borrower: loan.borrower
			})
		);

		// Deactivate loan.
		loan.isActive = false;

		// Set credit GHO allowance to 0.
		USER_SAFE.approveDelegateCreditGho(loan.borrower, 0);

		emit LoanRepaid(_loanId, msg.sender, loan.loanAmount, totalInterest);
	}

	/**
	 * @notice Liquidates a loan with crosschain collateral.
	 * @param _loanId ID of the loan.
	 * @param _receiver Address of the receiver.
	 */
	function liquidateLoanWhithCrosschainCollateral(
		uint256 _loanId,
		address _receiver
	) external nonReentrant {
		Loan storage loan = loans[_loanId];

		// Verify if the duration of the loan has passed.
		if (block.timestamp < loan.startTimestamp + loan.duration) {
			revert LoanStillActive(_loanId);
		}

		// Deactivate loan.
		loan.isActive = false;

		// Repay loan.
		GHO_TOKEN.safeTransferFrom(
			msg.sender,
			address(USER_SAFE),
			loan.loanAmount
		);

		// Seize collateral.
		USER_MESSENGER.sendRequest(
			loan.collateralChainId,
			messengers[loan.collateralChainId],
			IMessengerSepolia.Request({
				loanId: _loanId,
				collateralIdOrAmount: loan.collateralAmountOrId,
				action: 2,
				collateralType: loan.collateralType,
				collateralAddress: loan.collateralAddress,
				borrower: _receiver // The receiver is the liquidator.
			})
		);

		// Set credit GHO allowance to 0.
		USER_SAFE.approveDelegateCreditGho(loan.borrower, 0);

		emit LoanLiquidated(
			_loanId,
			loan.borrower,
			_receiver,
			loan.loanAmount,
			(loan.loanAmount * loan.interestRate) / 10000
		);
	}

	/**
	 * @notice Starts a loan.
	 * @param _loanId ID of the loan.
	 */
	function borrow(uint256 _loanId) external nonReentrant {
		// Verify that the loan is not active.
		Loan storage loan = loans[_loanId];
		if (loan.startTimestamp != 0) {
			revert LoanAlreadyBorrowed(_loanId);
		}
		if (loan.borrower != msg.sender) {
			revert WrongBorrower(msg.sender, loan.borrower);
		}

		// Transfer collateral to this contract.
		if (loan.collateralType == false) {
			IERC721(loan.collateralAddress).safeTransferFrom(
				msg.sender,
				address(USER_LOAN_SAFE),
				loan.collateralAmountOrId
			);
		} else {
			IERC20(loan.collateralAddress).safeTransferFrom(
				msg.sender,
				address(USER_LOAN_SAFE),
				loan.collateralAmountOrId
			);
		}

		// Approve loan amount to be transferred to borrower.
		USER_SAFE.approveDelegateCreditGho(loan.borrower, loan.loanAmount);

		// Update loan start timestamp.
		loan.startTimestamp = block.timestamp;
		loan.isActive = true;

		emit LoanStarted(_loanId, block.timestamp);
	}

	/**
	 * @notice Repays a loan.
	 * @param _loanId ID of the loan.
	 */
	function repay(uint256 _loanId) external nonReentrant {
		Loan storage loan = loans[_loanId];

		// Verify that the loan is active.
		if (!loan.isActive) {
			revert LoanNotActive(_loanId);
		}

		// Total interest to be paid.
		uint256 totalInterest = (loan.loanAmount * loan.interestRate) / 10000;

		// Total amount to be repaid (loan amount + interest)
		uint256 totalAmountToRepay = loan.loanAmount + totalInterest;

		// Transfer GHO tokens from borrower to safe.
		GHO_TOKEN.safeTransferFrom(
			msg.sender,
			address(USER_SAFE),
			totalAmountToRepay
		);

		// Transfer collateral back to borrower.
		USER_LOAN_SAFE.sendBackCollateral(_loanId);

		// Deactivate loan.
		loan.isActive = false;

		// Set credit GHO allowance to 0.
		USER_SAFE.approveDelegateCreditGho(loan.borrower, 0);

		emit LoanRepaid(_loanId, msg.sender, loan.loanAmount, totalInterest);
	}

	/**
	 * @notice Liquidates a loan.
	 * @param _loanId ID of the loan.
	 * @param _receiver Address of the receiver.
	 */
	function liquidateLoan(
		uint256 _loanId,
		address _receiver
	) external nonReentrant {
		Loan storage loan = loans[_loanId];

		// Verify if the duration of the loan has passed.
		if (block.timestamp < loan.startTimestamp + loan.duration) {
			revert LoanStillActive(_loanId);
		}

		// Deactivate loan.
		loan.isActive = false;

		// Repay loan.
		GHO_TOKEN.safeTransferFrom(
			msg.sender,
			address(USER_SAFE),
			loan.loanAmount
		);

		// Seize collateral.
		USER_LOAN_SAFE.seizeCollateral(_loanId, _receiver);

		// Set credit GHO allowance to 0.
		USER_SAFE.approveDelegateCreditGho(loan.borrower, 0);

		emit LoanLiquidated(
			_loanId,
			loan.borrower,
			_receiver,
			loan.loanAmount,
			(loan.loanAmount * loan.interestRate) / 10000
		);
	}
}
