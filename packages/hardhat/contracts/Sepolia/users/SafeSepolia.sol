// File: contracts/Sepolia/users/SafeSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ICreditDelegationToken } from "@aave/core-v3/contracts/interfaces/ICreditDelegationToken.sol";

import { LoanManagerSepolia } from "./LoanManagerSepolia.sol";
import { MailboxSepolia } from "./MailboxSepolia.sol";
import { AccessManagerSepolia } from "./AccessManagerSepolia.sol";
import { IAccessManagerSepolia } from "../interfaces/IAccessManagerSepolia.sol";
import { ISafeSepolia } from "../interfaces/ISafeSepolia.sol";

/**
 * @title SafeSepolia Contract
 * @author GhoSafe Protocol
 * @notice Walet contract for managing funds and interacting with Aave
 */
contract SafeSepolia is ISafeSepolia {
	/// @dev Aave's lending pool address on Sepolia: https://sepolia.etherscan.io/address/0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951
	IPool internal immutable AAVE_POOL;

	/// @dev GHO token address on Sepolia: https://sepolia.etherscan.io/address/0xc4bF5CbDaBE595361438F8c6a187bDc330539c60
	IERC20 internal immutable GHO_TOKEN;

	/// @dev Credit Delegation Token for GHO on Sepolia: https://sepolia.etherscan.io/address/0x67ae46EF043F7A4508BD1d6B94DB6c33F0915844
	ICreditDelegationToken internal immutable DEBT_GHO_TOKEN;

	/// @notice Access manager contract.
	IAccessManagerSepolia public immutable USER_ACCESS_MANAGER;

	/// @notice Address of the LoanManager contract.
	address public immutable USER_LOAN_MANAGER_ADDRESS;

	/// @notice Address of the Mailbox contract.
	address public immutable USER_MAILBOX_ADDRESS;

	/// @notice Referral code for Aave interactions.
	uint16 public immutable REFERRAL_CODE;

	/**
	 * @notice Constructor
	 * @param _ghoSafeIDSepolia Address of the GhoSafeIDSepolia contract
	 * @param _loanAdvertisementBook Address of the LoanAdvertisementBook contract
	 * @param _referralCode Referral code for Aave interactions
	 * @param _ghoToken Address of the GHO token
	 * @param _debtGhoToken Address of the Credit Delegation Token for GHO
	 * @param _pool Address of the Aave pool
	 * @param _router Address of the router contract
	 * @param _link Address of the LINK token
	 * @param _owner Address of the owner
	 */
	constructor(
		address _ghoSafeIDSepolia,
		address _loanAdvertisementBook,
		uint16 _referralCode,
		address _ghoToken,
		address _debtGhoToken,
		address _pool,
		address _router,
		address _link,
		address _owner
	) {
		USER_ACCESS_MANAGER = IAccessManagerSepolia(
			address(new AccessManagerSepolia(_owner))
		);
		USER_MAILBOX_ADDRESS = address(new MailboxSepolia(_ghoSafeIDSepolia));
		USER_LOAN_MANAGER_ADDRESS = address(
			new LoanManagerSepolia(
				USER_ACCESS_MANAGER,
				USER_MAILBOX_ADDRESS,
				_loanAdvertisementBook,
				_ghoToken,
				_debtGhoToken,
				_router,
				_link
			)
		);
		REFERRAL_CODE = _referralCode;
		AAVE_POOL = IPool(_pool);
		GHO_TOKEN = IERC20(_ghoToken);
		DEBT_GHO_TOKEN = ICreditDelegationToken(_debtGhoToken);
	}

	/// @dev Throws if called by any account other than the owner.
	modifier onlyOwner() {
		if (!USER_ACCESS_MANAGER.hasRole(keccak256("OWNER_ROLE"), msg.sender)) {
			revert UnauthorizedAccess(msg.sender);
		}
		_;
	}

	/**
	 * @notice Returns the balances of the specified tokens
	 * @param _tokens Addresses of the ERC20 tokens to check
	 * @return balances Balances of the specified tokens
	 */
	function getSafeBalances(
		address[] calldata _tokens
	) external view returns (uint256[] memory balances) {
		balances = new uint256[](_tokens.length);
		for (uint256 i = 0; i < _tokens.length; i++) {
			balances[i] = IERC20(_tokens[i]).balanceOf(address(this));
		}
	}

	/**
	 * @notice Adds an owner to the contract.
	 * @param _owner Address of the owner to add
	 */
	function addOwner(address _owner) external onlyOwner {
		USER_ACCESS_MANAGER.grantOwnerRole(_owner);
		emit OwnerAdded(_owner);
	}

	/**
	 * @notice Removes an owner from the contract.
	 * @param _owner Address of the owner to remove
	 */
	function removeOwner(address _owner) external onlyOwner {
		USER_ACCESS_MANAGER.revokeOwnerRole(_owner);
		emit OwnerRemoved(_owner);
	}

	/**
	 * @notice Withdraws a specific amount of ETH from the contract to a specified address.
	 * @param _to Address that will receive the ETH
	 * @param _amount Amount of ETH to withdraw
	 */
	function withdrawETHFromSafe(
		address payable _to,
		uint256 _amount
	) external payable onlyOwner {
		// Check if the contract has enough ETH
		if (address(this).balance < _amount) {
			revert NotEnoughBalance(address(0), _amount, address(this).balance);
		}

		// Transfer the ETH to the specified address
		(bool sent, bytes memory data) = _to.call{ value: _amount }("");

		// Revert if the transfer failed
		if (!sent) {
			revert ETHTtransferFailed(data);
		}

		// Emit event
		emit ETHWithdrawnFromSafe(_amount, _to);
	}

	/**
	 * @notice Withdraws a specific amount of an ERC20 token from the contract to a specified address.
	 * @param _to Address that will receive the token
	 * @param _token Address of the ERC20 token
	 * @param _amount Amount of the token to withdraw
	 */
	function withdrawFromSafe(
		address payable _to,
		address _token,
		uint256 _amount
	) external onlyOwner {
		// Check if the contract has enough tokens
		if (IERC20(_token).balanceOf(address(this)) < _amount) {
			revert NotEnoughBalance(
				_token,
				_amount,
				IERC20(_token).balanceOf(address(this))
			);
		}

		// Transfer the tokens to the specified address
		IERC20(_token).transfer(_to, _amount);

		// Emit event
		emit ERC20WithdrawnFromSafe(_token, _amount, _to);
	}

	/**
	 * @notice Supplies a specific amount of an ERC20 token to Aave.
	 * @param _token Address of the ERC20 token
	 * @param _amount Amount of the token to supply
	 */
	function supplyToAave(address _token, uint256 _amount) external onlyOwner {
		if (IERC20(_token).balanceOf(address(this)) < _amount) {
			revert NotEnoughBalance(
				_token,
				_amount,
				IERC20(_token).balanceOf(address(this))
			);
		}
		// Approve the Aave pool to spend the token
		IERC20(_token).approve(address(AAVE_POOL), _amount);

		// Supply the token to Aave
		AAVE_POOL.supply(_token, _amount, address(this), REFERRAL_CODE);

		// Emit event
		emit TokenSuppliedToAave(_token, _amount);
	}

	/**
	 * @notice Withdraws a specific amount of an ERC20 token from Aave.
	 * @param _token Address of the ERC20 token
	 * @param _amount Amount of the token to withdraw
	 */
	function withdrawFromAave(
		address _token,
		uint256 _amount
	) external onlyOwner {
		// Withdraw the token from Aave
		AAVE_POOL.withdraw(_token, _amount, address(this));

		// Emit event
		emit TokenWithdrawnFromAave(_token, _amount);
	}

	/**
	 * @notice Borrows a specific amount of an ERC20 token from Aave.
	 * @param _token Address of the ERC20 token
	 * @param _amount Amount of the token to borrow
	 * @param _interestRateMode Interest rate mode for the borrow
	 */
	function borrowFromAave(
		address _token,
		uint256 _amount,
		uint256 _interestRateMode
	) external onlyOwner {
		// Borrow the token from Aave
		AAVE_POOL.borrow(
			_token,
			_amount,
			_interestRateMode,
			REFERRAL_CODE,
			address(this)
		);

		// Emit event
		emit TokenBorrowedFromAave(_token, _amount);
	}

	/**
	 * @notice Repays a specific amount of an ERC20 token to Aave.
	 * @param _token Address of the ERC20 token
	 * @param _amount Amount of the token to repay
	 * @param _rateMode Interest rate mode for the repay
	 */
	function repayToAave(
		address _token,
		uint256 _amount,
		uint256 _rateMode
	) external onlyOwner {
		// Approve the Aave pool to spend the token
		IERC20(_token).approve(address(AAVE_POOL), _amount);

		// Repay the token to Aave
		AAVE_POOL.repay(_token, _amount, _rateMode, address(this));

		// Emit event
		emit TokenRepaidToAave(_token, _amount);
	}

	/**
	 * @notice Borrows GHO from Aave.
	 * @param _amount Amount of GHO to borrow
	 */
	function borrowGho(uint256 _amount) external onlyOwner {
		// Borrow GHO from Aave
		AAVE_POOL.borrow(
			address(GHO_TOKEN),
			_amount,
			2,
			REFERRAL_CODE,
			address(this)
		);

		// Emit event
		emit TokenBorrowedFromAave(address(GHO_TOKEN), _amount);
	}

	/**
	 * @notice Repays GHO to Aave.
	 * @param _amount Amount of GHO to repay
	 */
	function repayGho(uint256 _amount) external onlyOwner {
		// Approve the Aave pool to spend GHO
		IERC20(address(GHO_TOKEN)).approve(address(AAVE_POOL), _amount);

		// Repay GHO to Aave
		AAVE_POOL.repay(address(GHO_TOKEN), _amount, 2, address(this));

		// Emit event
		emit TokenRepaidToAave(address(GHO_TOKEN), _amount);
	}

	/**
	 * @notice Approves a delegatee to spend a specific amount of GHO.
	 * @param _delegatee Address of the delegatee
	 * @param _amount Amount of GHO to approve
	 */
	function approveDelegateCreditGho(
		address _delegatee,
		uint256 _amount
	) external {
		// Check if the caller is the LoanManager contract
		if (msg.sender != USER_LOAN_MANAGER_ADDRESS) {
			revert UnauthorizedAccess(msg.sender);
		}

		// Approve the delegatee to spend GHO
		DEBT_GHO_TOKEN.approveDelegation(_delegatee, _amount);

		// Emit event
		emit CreditDelegateApproved(_delegatee, _amount);
	}

	/// @notice Fallback function to receive ETH with data
	receive() external payable {
		emit ReceivedETH(msg.value, msg.sender);
	}

	/// @notice Fallback function to receive ETH without data
	fallback() external payable {
		emit ReceivedETH(msg.value, msg.sender);
	}
}
