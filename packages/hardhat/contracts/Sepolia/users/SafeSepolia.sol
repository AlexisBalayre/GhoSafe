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
	IPool internal constant POOL =
		IPool(0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951);

	/// @dev GHO token address on Sepolia: https://sepolia.etherscan.io/address/0xc4bF5CbDaBE595361438F8c6a187bDc330539c60
	IERC20 internal constant GHO_TOKEN =
		IERC20(0xc4bF5CbDaBE595361438F8c6a187bDc330539c60);

	/// @dev Credit Delegation Token for GHO on Sepolia: https://sepolia.etherscan.io/address/0xd4FEA5bD40cE7d0f7b269678541fF0a95FCb4b68
	ICreditDelegationToken internal constant DEBT_GHO_TOKEN =
		ICreditDelegationToken(0xd4FEA5bD40cE7d0f7b269678541fF0a95FCb4b68);

	/// @notice Access manager contract.
	IAccessManagerSepolia public immutable USER_ACCESS_MANAGER;

	/// @notice Address of the LoanManager contract.
	address public immutable USER_LOAN_MANAGER_ADDRESS;

	/// @notice Address of the Mailbox contract.
	address public immutable USER_MAILBOX_ADDRESS;

	/// @dev Referral code for Aave interactions
	uint16 internal REFERRAL_CODE;

	/**
	 * @notice Constructor
	 * @param _referralCode Referral code for Aave interactions
	 * @param _ghoSafeIDSepolia Address of the GhoSafeIDSepolia contract
	 * @param _loanAdvertisementBook Address of the LoanAdvertisementBook contract
	 * @param _router Address of the router contract
	 * @param _link Address of the LINK token
	 */
	constructor(
		uint16 _referralCode,
		address _ghoSafeIDSepolia,
		address _loanAdvertisementBook,
		address _router,
		address _link
	) {
		REFERRAL_CODE = _referralCode;
		USER_ACCESS_MANAGER = IAccessManagerSepolia(
			address(new AccessManagerSepolia(msg.sender))
		);
		USER_MAILBOX_ADDRESS = address(new MailboxSepolia(_ghoSafeIDSepolia));
		USER_LOAN_MANAGER_ADDRESS = address(
			new LoanManagerSepolia(
				USER_ACCESS_MANAGER,
				USER_MAILBOX_ADDRESS,
				_loanAdvertisementBook,
				_router,
				_link
			)
		);
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
		if (address(this).balance < _amount) {
			revert NotEnoughBalance(address(0), _amount, address(this).balance);
		}
		(bool sent, bytes memory data) = _to.call{ value: _amount }("");
		if (!sent) {
			revert ETHTtransferFailed(data);
		}
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
		if (IERC20(_token).balanceOf(address(this)) < _amount) {
			revert NotEnoughBalance(
				_token,
				_amount,
				IERC20(_token).balanceOf(address(this))
			);
		}
		IERC20(_token).transfer(_to, _amount);
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
		IERC20(_token).approve(address(POOL), _amount);
		POOL.supply(_token, _amount, address(this), REFERRAL_CODE);
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
		POOL.withdraw(_token, _amount, address(this));
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
		POOL.borrow(
			_token,
			_amount,
			_interestRateMode,
			REFERRAL_CODE,
			address(this)
		);
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
		POOL.repay(_token, _amount, _rateMode, address(this));
		emit TokenRepaidToAave(_token, _amount);
	}

	/**
	 * @notice Borrows GHO from Aave.
	 * @param _amount Amount of GHO to borrow
	 */
	function borrowGho(uint256 _amount) external onlyOwner {
		POOL.borrow(
			address(GHO_TOKEN),
			_amount,
			2,
			REFERRAL_CODE,
			address(this)
		);
		emit TokenBorrowedFromAave(address(GHO_TOKEN), _amount);
	}

	/**
	 * @notice Repays GHO to Aave.
	 * @param _amount Amount of GHO to repay
	 */
	function repayGho(uint256 _amount) external onlyOwner {
		POOL.repay(address(GHO_TOKEN), _amount, 2, address(this));
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
		if (msg.sender != USER_LOAN_MANAGER_ADDRESS) {
			revert UnauthorizedAccess(msg.sender);
		}
		DEBT_GHO_TOKEN.approveDelegation(_delegatee, _amount);
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
