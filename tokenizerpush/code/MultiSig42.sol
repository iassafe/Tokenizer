// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


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
        address to;
        uint256 amount;
        bool    executed;
        uint256 confirmations;
    }

    // ----------------------------------------------------------------
    // State
    // ----------------------------------------------------------------

    IERC20 public immutable token;

    address[] public owners;

    mapping(address => bool) public isOwner;

    uint256 public immutable requiredConfirmations;

    Transaction[] public transactions;

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

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function transactionCount() external view returns (uint256) {
        return transactions.length;
    }

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
