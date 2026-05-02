# Deployment Guide — iassafe42 & MultiSig42

## Network

| Field          | Value                                    |
|----------------|------------------------------------------|
| Network        | Ethereum Sepolia Testnet                 |
| Chain ID       | 11155111                                 |
| Currency       | SepoliaETH — free, no real money needed  |
| RPC URL        | https://rpc.sepolia.org                  |
| Block Explorer | https://sepolia.etherscan.io             |

---

## Deployed Contract Addresses

| Contract     | Address                    | Explorer                                                 |
|--------------|----------------------------|----------------------------------------------------------|
| `iassafe42`  | *(paste after deployment)* | https://sepolia.etherscan.io/token/\<address\>           |
| `MultiSig42` | *(paste after deployment)* | https://sepolia.etherscan.io/address/\<address\>         |

> Ticker visible on Etherscan: **IAS42**
> Token name visible on Etherscan: **iassafe42**

---

## Transaction Record

| Action                        | Tx Hash   | Block     |
|-------------------------------|-----------|-----------|
| Deploy `iassafe42`            | *(paste)* | *(paste)* |
| Deploy `MultiSig42`           | *(paste)* | *(paste)* |
| Fund MultiSig42 with IAS42    | *(paste)* | *(paste)* |
| `approve` MultiSig42          | *(paste)* | *(paste)* |
| `transferFrom` via MultiSig42 | *(paste)* | *(paste)* |

---

## Prerequisites

### 1 — Install MetaMask
- Download: https://metamask.io
- Create a wallet and save your seed phrase securely.
- Switch to **Sepolia** network:
  MetaMask → Settings → Networks → Add a network → Sepolia Testnet

### 2 — Get Free SepoliaETH
No real money needed. Use the free faucet:
```
https://cloud.google.com/application/web3/faucet/ethereum/sepolia
```
Enter your wallet address → receive **0.05 SepoliaETH** (enough for many deployments).

### 3 — Open Remix IDE
```
https://remix.ethereum.org
```
No installation required — runs entirely in the browser.

---

## Deploy iassafe42 (Mandatory)

### Step 1 — Load the file
In the Remix **File Explorer** (left panel), create `iassafe42.sol`
and paste the content from `code/iassafe42.sol`.

### Step 2 — Compile
1. Click the **Solidity Compiler** tab.
2. Compiler version: `0.8.20`
3. Enable **Optimization** → 200 runs.
4. Click **Compile iassafe42.sol**.
5. Green checkmark ✅ confirms success.

### Step 3 — Deploy
1. Click the **Deploy & Run Transactions** tab.
2. Environment: `Injected Provider – MetaMask`
3. Confirm MetaMask is on **Sepolia**.
4. Contract: `iassafe42`
5. Click **Deploy** → confirm in MetaMask.

### Step 4 — Confirm
1. Copy the contract address from the Remix console.
2. Go to https://sepolia.etherscan.io and search the address.
3. You should see **IAS42** with total supply **42,000,000**.

---

## Deploy MultiSig42 (Bonus)

### Step 1 — Load and compile
Create `MultiSig42.sol` in Remix, paste from `code/MultiSig42.sol`,
compile with the same settings (0.8.20, optimization 200).

### Step 2 — Constructor arguments

| Argument                 | Value                                        |
|--------------------------|----------------------------------------------|
| `_token`                 | Address of deployed `iassafe42`              |
| `_owners`                | `["0xOwner1Address","0xOwner2Address"]`       |
| `_requiredConfirmations` | `2`                                          |

> Create a second MetaMask account for Owner 2:
> MetaMask → click account icon → **Add account**

### Step 3 — Deploy
1. In the Deploy tab, select contract `MultiSig42`.
2. Expand the constructor fields, fill in the three arguments.
3. Click **Deploy** → confirm in MetaMask.

### Step 4 — Fund the MultiSig wallet
The contract needs IAS42 tokens before it can transfer them.
Load the deployed `iassafe42` contract in Remix (**At Address** field), then call:
```
transfer(
  to     : <MultiSig42 contract address>
  amount : 1000000000000000000000   // 1000 IAS42
)
```

---

## Demonstrate the Token (for evaluation)

### Basic ERC-20 actions

```
// Check balance
balanceOf("0xYourAddress")
// result is in wei — divide by 10^18 to get IAS42

// Send 10 IAS42
transfer("0xRecipient", 10000000000000000000)

// Allow a spender to use 5 IAS42
approve("0xSpender", 5000000000000000000)

// Delegated transfer
transferFrom("0xYourAddress", "0xRecipient", 5000000000000000000)
```

### MultiSig transfer demo

```
// Owner 1: propose a transfer of 100 IAS42
submitTransaction("0xRecipient", 100000000000000000000)
// → txId = 0

// Owner 1: confirm
confirmTransaction(0)

// Switch MetaMask to Owner 2 — confirm
confirmTransaction(0)
// confirmations = 2, threshold met ✓

// Either owner: execute
executeTransaction(0)
// → 100 IAS42 sent ✓
```

---

## Security Notes

- **No API key or password** is stored anywhere in this repository.
- All transactions are signed locally by MetaMask — your private key never leaves your browser.
- Sepolia is a testnet — SepoliaETH has **no monetary value**.
