// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ============================================================
//  MultiSig42 — Multisignature Wallet (Bonus)
//  Controls iassafe42 (IAS42) token transfers.
//  Requires multiple owner approvals before any transfer executes.
// ============================================================

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title   MultiSig42
 * @notice  A multisig wallet for IAS42 tokens.
 *          Owners submit → confirm → execute token transfers.
 *          A transfer only goes through once `requiredConfirmations`
 *          approvals have been collected.
 */
contract MultiSig42 {

    // ----------------------------------------------------------------
    // Events
    // ----------------------------------------------------------------

    event TransactionSubmitted(
        uint256 indexed txId,
        address indexed submitter,
        address indexed to,
        uint256 amount
    );
    event TransactionConfirmed(uint256 indexed txId, address indexed owner);
    event ConfirmationRevoked(uint256 indexed txId, address indexed owner);
    event TransactionExecuted(uint256 indexed txId);

    // ----------------------------------------------------------------
    // Structs
    // ----------------------------------------------------------------

    struct Transaction {
        address to;             // Recipient
        uint256 amount;         // IAS42 amount (18 decimals)
        bool    executed;       // True once executed
        uint256 confirmations;  // Number of approvals
    }

    // ----------------------------------------------------------------
    // State
    // ----------------------------------------------------------------

    /// @notice The IAS42 token this multisig controls
    IERC20 public immutable token;

    /// @notice Ordered list of authorised signers
    address[] public owners;

    /// @notice Quick ownership lookup
    mapping(address => bool) public isOwner;

    /// @notice Minimum approvals needed to execute
    uint256 public immutable requiredConfirmations;

    /// @notice All submitted transactions
    Transaction[] public transactions;

    /// @notice txId → owner → confirmed?
    mapping(uint256 => mapping(address => bool)) public hasConfirmed;

    // ----------------------------------------------------------------
    // Modifiers
    // ----------------------------------------------------------------

    modifier onlyOwner() {
        require(isOwner[msg.sender], "MultiSig42: not an owner");
        _;
    }

    modifier txExists(uint256 txId) {
        require(txId < transactions.length, "MultiSig42: tx does not exist");
        _;
    }

    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].executed, "MultiSig42: already executed");
        _;
    }

    modifier notConfirmed(uint256 txId) {
        require(!hasConfirmed[txId][msg.sender], "MultiSig42: already confirmed");
        _;
    }

    // ----------------------------------------------------------------
    // Constructor
    // ----------------------------------------------------------------

    /**
     * @param _token                 Address of the deployed iassafe42 contract
     * @param _owners                Authorised signer addresses (min 2)
     * @param _requiredConfirmations Minimum approvals to execute (min 2)
     */
    constructor(
        address _token,
        address[] memory _owners,
        uint256 _requiredConfirmations
    ) {
        require(_token != address(0), "MultiSig42: invalid token");
        require(_owners.length >= 2, "MultiSig42: need at least 2 owners");
        require(
            _requiredConfirmations >= 2 &&
            _requiredConfirmations <= _owners.length,
            "MultiSig42: invalid confirmations"
        );

        token = IERC20(_token);
        requiredConfirmations = _requiredConfirmations;

        for (uint256 i = 0; i < _owners.length; i++) {
            address o = _owners[i];
            require(o != address(0), "MultiSig42: zero address");
            require(!isOwner[o], "MultiSig42: duplicate owner");
            isOwner[o] = true;
            owners.push(o);
        }
    }

    // ----------------------------------------------------------------
    // Core workflow
    // ----------------------------------------------------------------

    /**
     * @notice Propose a new token transfer.
     * @param  to     Recipient address
     * @param  amount IAS42 amount to transfer
     * @return txId   ID of the created transaction
     */
    function submitTransaction(address to, uint256 amount)
        external
        onlyOwner
        returns (uint256 txId)
    {
        require(to != address(0), "MultiSig42: invalid recipient");
        require(amount > 0, "MultiSig42: amount must be > 0");

        txId = transactions.length;
        transactions.push(Transaction({
            to:            to,
            amount:        amount,
            executed:      false,
            confirmations: 0
        }));

        emit TransactionSubmitted(txId, msg.sender, to, amount);
    }

    /**
     * @notice Approve a pending transaction.
     * @param  txId Transaction ID
     */
    function confirmTransaction(uint256 txId)
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
        notConfirmed(txId)
    {
        hasConfirmed[txId][msg.sender] = true;
        transactions[txId].confirmations += 1;
        emit TransactionConfirmed(txId, msg.sender);
    }

    /**
     * @notice Withdraw a previously given approval.
     * @param  txId Transaction ID
     */
    function revokeConfirmation(uint256 txId)
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
    {
        require(hasConfirmed[txId][msg.sender], "MultiSig42: not confirmed");
        hasConfirmed[txId][msg.sender] = false;
        transactions[txId].confirmations -= 1;
        emit ConfirmationRevoked(txId, msg.sender);
    }

    /**
     * @notice Execute a transaction once enough confirmations are gathered.
     * @dev    The contract must hold sufficient IAS42 tokens.
     * @param  txId Transaction ID
     */
    function executeTransaction(uint256 txId)
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
    {
        Transaction storage t = transactions[txId];
        require(
            t.confirmations >= requiredConfirmations,
            "MultiSig42: not enough confirmations"
        );

        t.executed = true;
        require(
            token.transfer(t.to, t.amount),
            "MultiSig42: transfer failed"
        );

        emit TransactionExecuted(txId);
    }

    // ----------------------------------------------------------------
    // View helpers
    // ----------------------------------------------------------------

    /// @notice Returns all owner addresses
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    /// @notice Returns the number of transactions ever submitted
    function transactionCount() external view returns (uint256) {
        return transactions.length;
    }

    /// @notice Returns full details of a transaction
    function getTransaction(uint256 txId)
        external
        view
        txExists(txId)
        returns (address to, uint256 amount, bool executed, uint256 confirmations)
    {
        Transaction storage t = transactions[txId];
        return (t.to, t.amount, t.executed, t.confirmations);
    }
}
