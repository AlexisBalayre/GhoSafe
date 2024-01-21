// File: contracts/Sepolia/interfaces/ISafeSepolia.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title ISafeSepolia Contract Interface
 * @author GhoSafe Protocol
 * @notice Interface for the SafeSepolia contract
 * @dev This interface should be implemented by the SafeSepolia contract.
 */
interface ISafeSepolia {
	/// @notice ETH transfer failed error
	error ETHTtransferFailed(bytes data);
	/// @notice Not enough balance error
	error NotEnoughBalance(address token, uint256 amount, uint256 balance);
	/// @notice Unauthorized access error
	error UnauthorizedAccess(address caller);

	/**
	 * @notice Event emitted when a new owner is added
	 * @param owner Address of the new owner
	 */
	event OwnerAdded(address indexed owner);

	/**
	 * @notice Event emitted when an owner is removed
	 * @param owner Address of the removed owner
	 */
	event OwnerRemoved(address indexed owner);

	/**
	 * @notice Event emitted when ETH is withdrawn from the safe
	 * @param amount Amount of ETH withdrawn
	 * @param to Address that received the ETH
	 */
	event ETHWithdrawnFromSafe(uint256 amount, address indexed to);

	/**
	 * @notice Event emitted when a ERC20 is withdrawn from the safe
	 * @param token Address of the token withdrawn
	 * @param amount Amount of the token withdrawn
	 * @param to Address that received the token
	 */
	event ERC20WithdrawnFromSafe(
		address indexed token,
		uint256 amount,
		address indexed to
	);

	/**
	 * @notice Event emitted when a ERC20 is supplied to Aave
	 * @param token Address of the token supplied
	 * @param amount Amount of the token supplied
	 */
	event TokenSuppliedToAave(address indexed token, uint256 amount);

	/**
	 * @notice Event emitted when a ERC20 is withdrawn from Aave
	 * @param token Address of the token withdrawn
	 * @param amount Amount of the token withdrawn
	 */
	event TokenWithdrawnFromAave(address indexed token, uint256 amount);

	/**
	 * @notice Event emitted when a ERC20 is borrowed from Aave
	 * @param token Address of the token borrowed
	 * @param amount Amount of the token borrowed
	 */
	event TokenBorrowedFromAave(address indexed token, uint256 amount);

	/**
	 * @notice Event emitted when a ERC20 is repaid to Aave
	 * @param token Address of the token repaid
	 * @param amount Amount of the token repaid
	 */
	event TokenRepaidToAave(address indexed token, uint256 amount);

	/**
	 * @notice Event emitted ETH is received by the contract
	 * @param amount Amount of ETH received
	 * @param from Address that sent the ETH
	 */
	event ReceivedETH(uint256 amount, address indexed from);

	/**
	 * @notice Event emitted when a delegatee is approved to spend a specific amount of GHO
	 * @param delegatee Address of the delegatee
	 * @param amount Amount of GHO approved
	 */
	event CreditDelegateApproved(address indexed delegatee, uint256 amount);

	/**
	 * @notice Returns the balances of the specified tokens
	 * @param _tokens Addresses of the ERC20 tokens to check
	 * @return balances Balances of the specified tokens
	 */
	function getSafeBalances(
		address[] calldata _tokens
	) external view returns (uint256[] memory balances);

	/**
	 * @notice Withdraws a specific amount of ETH from the contract to a specified address.
	 * @param _to Address that will receive the ETH
	 * @param _amount Amount of ETH to withdraw
	 */
	function withdrawETHFromSafe(
		address payable _to,
		uint256 _amount
	) external payable;

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
	) external;

	/**
	 * @notice Supplies a specific amount of an ERC20 token to Aave.
	 * @param _token Address of the ERC20 token
	 * @param _amount Amount of the token to supply
	 */
	function supplyToAave(address _token, uint256 _amount) external;

	/**
	 * @notice Withdraws a specific amount of an ERC20 token from Aave.
	 * @param _token Address of the ERC20 token
	 * @param _amount Amount of the token to withdraw
	 */
	function withdrawFromAave(address _token, uint256 _amount) external;

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
	) external;

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
	) external;

	/**
	 * @notice Borrows GHO from Aave.
	 * @param _amount Amount of GHO to borrow
	 */
	function borrowGho(uint256 _amount) external;

	/**
	 * @notice Repays GHO to Aave.
	 * @param _amount Amount of GHO to repay
	 */
	function repayGho(uint256 _amount) external;

	/**
	 * @notice Approves a delegatee to spend a specific amount of GHO.
	 * @param _delegatee Address of the delegatee
	 * @param _amount Amount of GHO to approve
	 */
	function approveDelegateCreditGho(
		address _delegatee,
		uint256 _amount
	) external;

	/// @notice Fallback function to receive ETH with data
	receive() external payable;

	/// @notice Fallback function to receive ETH without data
	fallback() external payable;
}
