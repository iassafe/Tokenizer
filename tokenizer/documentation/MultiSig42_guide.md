# MultiSig42 — Multisignature Wallet Guide

## Overview

`MultiSig42` is a multisignature wallet smart contract that controls **IAS42 token
transfers**. It requires at least **2 owner approvals** before any transfer can execute.

This prevents a single compromised wallet from moving funds — every transaction must
be agreed upon by multiple parties.

| Property               | Value                                      |
|------------------------|------------------------------------------- |
| Contract               | MultiSig42                                 |
| Network                | Ethereum Sepolia Testnet                   |
| Controls token         | iassafe42 (IAS42)                          |
| Minimum owners         | 2                                          |
| Minimum confirmations  | 2                                          |
| Contract Address       | 0xAD80F440160B5244602E2d59C56b719964234aa7 |

---

## How It Works

Every token transfer follows three stages — in strict order:

```
  SUBMIT                   CONFIRM (×N)               EXECUTE
    │                           │                         │
 Any owner               Each owner                  Any owner
 proposes           approves one by one            sends tokens once
 a transfer    ──►  until threshold met   ──►      threshold is reached
```

No single owner can skip steps. `executeTransaction` will revert until enough
confirmations are collected.

---

## Constructor Parameters

When deploying, you must provide three arguments:

| Parameter                 | Type        | Rules                             | Description |
|---------------------------|-------------|-----------------------------------|-------------|
| `_token`                  | `address`   | Non-zero                          | Address of the deployed `iassafe42` contract |
| `_owners`                 | `address[]` | Min 2, no duplicates, no zero address | List of authorized signer wallets |
| `_requiredConfirmations`  | `uint256`   | Min 2, max = owner count          | How many approvals are needed |

**Example (Remix constructor fields):**
```
_token                 : "0xYourIassafe42ContractAddress"
_owners                : ["0xOwner1Address","0xOwner2Address"]
_requiredConfirmations : 2
```

---

## All Functions

### Write Functions (require gas)

#### `submitTransaction(to, amount)` → `uint256 txId`
Propose a new IAS42 transfer.

| Parameter | Type      | Description |
|-----------|-----------|-------------|
| `to`      | `address` | Recipient of the IAS42 tokens |
| `amount`  | `uint256` | Amount in wei (1 IAS42 = 10¹⁸) |

- Only callable by an owner.
- Does **not** send tokens — only records the proposal.
- Returns the `txId` (starts at 0, increments by 1 each time).

---

#### `confirmTransaction(txId)`
Approve a pending transaction.

| Parameter | Type      | Description |
|-----------|-----------|-------------|
| `txId`    | `uint256` | ID of the transaction to approve |

- Only callable by an owner.
- Each owner can only confirm once per transaction.
- Transaction must exist and not be already executed.

---

#### `revokeConfirmation(txId)`
Withdraw a previously given approval.

| Parameter | Type      | Description |
|-----------|-----------|-------------|
| `txId`    | `uint256` | ID of the transaction to un-approve |

- Only callable by an owner who already confirmed this transaction.
- Transaction must not be already executed.
- Decreases the confirmation count by 1.

---

#### `executeTransaction(txId)`
Send the tokens once enough approvals are collected.

| Parameter | Type      | Description |
|-----------|-----------|-------------|
| `txId`    | `uint256` | ID of the transaction to execute |

- Only callable by an owner.
- Requires `confirmations >= requiredConfirmations` — otherwise reverts.
- The `MultiSig42` contract must hold enough IAS42 tokens.
- Sets `executed = true` **before** calling `token.transfer()` (re-entrancy protection).
- A transaction can only be executed once.

---

### Read Functions (free — no gas)

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `getOwners()` | — | `address[]` | All authorized signer addresses |
| `transactionCount()` | — | `uint256` | Total transactions ever submitted |
| `getTransaction(txId)` | `uint256` | `to, amount, executed, confirmations` | Full details of one transaction |
| `isOwner(address)` | `address` | `bool` | Whether an address is an owner |
| `hasConfirmed(txId, address)` | `uint256, address` | `bool` | Whether an owner confirmed a tx |
| `requiredConfirmations()` | — | `uint256` | Minimum approvals needed |
| `token()` | — | `address` | Address of the controlled IAS42 contract |

---

## Events

| Event | Emitted when | Parameters |
|-------|-------------|-----------|
| `TransactionSubmitted` | New transaction proposed | `txId`, `submitter`, `to`, `amount` |
| `TransactionConfirmed` | An owner approves | `txId`, `owner` |
| `ConfirmationRevoked` | An owner withdraws approval | `txId`, `owner` |
| `TransactionExecuted` | Transfer successfully sent | `txId` |

---

## Security Model

| Threat | Protection in MultiSig42 |
|--------|--------------------------|
| Single key compromised | Transfer still blocked — other owners must approve |
| Owner tries to execute early | `require(confirmations >= requiredConfirmations)` reverts |
| Re-entrancy attack | `executed = true` set **before** `token.transfer()` call |
| Duplicate owner at setup | Constructor: `require(!isOwner[o])` rejects duplicates |
| Zero-address owner or recipient | `require(addr != address(0))` in constructor and submit |
| Token address swapped after deploy | `token` is `immutable` — set once, can never change |
| Double execution | `notExecuted` modifier blocks second execution |

---

## Step-by-Step: Deploy MultiSig42

### Requirements
- `iassafe42` already deployed — you need its contract address.
- Two MetaMask wallet addresses to act as owners.
  *(In MetaMask: click account icon → Add account to create a second one)*
- SepoliaETH for gas.

### 1. Load and compile
In Remix, create `MultiSig42.sol`, paste from `code/MultiSig42.sol`.
Compile with Solidity 0.8.20, optimization 200 runs.

### 2. Fill constructor arguments in Remix
```
_token                 : "0x...iassafe42 address..."
_owners                : ["0x...Owner1...","0x...Owner2..."]
_requiredConfirmations : 2
```

### 3. Deploy
Click **Deploy** → confirm in MetaMask.
Copy the contract address from the Remix console.

### 4. Fund the wallet
`MultiSig42` must hold IAS42 to transfer them.
Load the `iassafe42` contract in Remix (paste address in **At Address**), then call:
```
transfer(
  to     : <MultiSig42 address>
  amount : 1000000000000000000000   // 1000 IAS42
)
```

---

## Step-by-Step: Full Transfer Demo (2 owners)

This example uses `requiredConfirmations = 2`.

**Switch MetaMask to Owner 1:**

```
// Propose: send 100 IAS42 to a recipient
submitTransaction("0xRecipientAddress", 100000000000000000000)
// → txId = 0

// Owner 1 approves
confirmTransaction(0)
// confirmations = 1
```

**Switch MetaMask to Owner 2:**

```
// Owner 2 approves — threshold is now met
confirmTransaction(0)
// confirmations = 2 ✓
```

**Either owner executes:**

```
executeTransaction(0)
// → 100 IAS42 transferred to recipient ✓
// → TransactionExecuted event emitted
```

**Optional — Revoke before execution:**

```
// Owner 1 changes their mind before execution
revokeConfirmation(0)
// confirmations drops back to 1 — execution is blocked again
```

---

## Notes

- The `MultiSig42` contract is the **token sender** — individual owners are just signers.
- You must fund the contract with IAS42 before any `executeTransaction` can succeed.
- All transactions remain on-chain permanently, even after execution, for full auditability.
- Owners cannot be added or removed after deployment — this is intentional to keep the contract simple and auditable.

