# iassafe42 (IAS42) — Token Guide

## Overview

`iassafe42` is a standard ERC-20 token deployed on the Ethereum Sepolia testnet.

| Property          | Value                          |
|-------------------|-------------------------------|
| Name              | iassafe42                      |
| Symbol / Ticker   | IAS42                          |
| Standard          | ERC-20                         |
| Network           | Ethereum Sepolia Testnet       |
| Decimals          | 18                             |
| Total Supply      | 42,000,000 IAS42               |
| Contract Address  | *(see README.md)*              |
| Explorer          | https://sepolia.etherscan.io   |

---

## Contract Source

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract iassafe42 is ERC20 {

    constructor() ERC20("iassafe42", "IAS42") {
        _mint(msg.sender, 42_000_000 * (10 ** 18));
    }
}
```

---

## How It Works

The contract inherits from OpenZeppelin's `ERC20`. In the constructor:

1. The token is named `"iassafe42"` with symbol `"IAS42"`.
2. `_mint()` creates exactly **42,000,000 IAS42** (with 18 decimals) and
   sends them all to `msg.sender` (the deployer's wallet).

After deployment:
- There is no `mint()` function — the supply can **never increase**.
- There is no `owner` or admin role — the deployer has no special privileges.
- Any wallet can send and receive IAS42 like any other ERC-20 token.

---

## All Functions

### Read Functions (free — no gas)

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `name()` | — | `string` | Returns `"iassafe42"` |
| `symbol()` | — | `string` | Returns `"IAS42"` |
| `decimals()` | — | `uint8` | Returns `18` |
| `totalSupply()` | — | `uint256` | Total supply in wei (42000000 × 10¹⁸) |
| `balanceOf(account)` | `address account` | `uint256` | Token balance of `account` in wei |
| `allowance(owner, spender)` | `address owner`, `address spender` | `uint256` | Remaining tokens `spender` can use on behalf of `owner` |

### Write Functions (require gas)

| Function | Parameters | Description |
|----------|-----------|-------------|
| `transfer(to, amount)` | `address to`, `uint256 amount` | Send `amount` tokens from your wallet to `to` |
| `approve(spender, amount)` | `address spender`, `uint256 amount` | Allow `spender` to spend up to `amount` on your behalf |
| `transferFrom(from, to, amount)` | `address from`, `address to`, `uint256 amount` | Move tokens on behalf of `from` (must have prior approval) |

> **Amount units:** all amounts are in wei (1 IAS42 = 1,000,000,000,000,000,000 = 10¹⁸ wei)

---

## Security

| Feature | Detail |
|---------|--------|
| Fixed supply | No mint function after construction — 42M forever |
| No owner privileges | Deployer cannot pause, burn, or take tokens from others |
| Overflow protection | Solidity 0.8.20 reverts on integer overflow/underflow |
| Audited base | OpenZeppelin ERC20 — no custom transfer logic |
| Zero-address guard | OpenZeppelin rejects transfers to `address(0)` |

---

## Step-by-Step: Deploy on Sepolia

### Requirements
- MetaMask wallet set to **Sepolia** network
- At least 0.01 SepoliaETH (get free ETH: https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

### 1. Open Remix IDE
```
https://remix.ethereum.org
```

### 2. Create the file
In the File Explorer panel → **+ Create file** → name it `iassafe42.sol`
→ paste the contract source code from `code/iassafe42.sol`.

### 3. Compile
- Solidity Compiler tab → version `0.8.20`
- Enable Optimization → 200 runs
- Click **Compile iassafe42.sol**
- ✅ Green checkmark = success

### 4. Deploy
- Deploy & Run Transactions tab
- Environment: **Injected Provider – MetaMask**
- Confirm MetaMask is on **Sepolia**
- Contract: `iassafe42`
- Click **Deploy** → confirm MetaMask popup

### 5. Verify
- Copy contract address from Remix console
- Search it on https://sepolia.etherscan.io
- Token Tracker should show **IAS42 — 42,000,000 supply**

---

## Step-by-Step: Use the Token in Remix

### Check your balance
In Remix, expand `balanceOf`, enter your wallet address, click **call**.
Result is in wei — divide by 10¹⁸ to get IAS42.

### Send tokens
Expand `transfer`:
```
to     : 0xRecipientAddress
amount : 1000000000000000000    (= 1 IAS42)
```
Click **transact** → confirm in MetaMask.

### Approve a spender
Expand `approve`:
```
spender : 0xSpenderAddress
amount  : 5000000000000000000   (= 5 IAS42)
```
Click **transact**.

### Delegated transfer (transferFrom)
After an `approve`, the spender calls:
```
from   : 0xOriginalOwner
to     : 0xRecipient
amount : 5000000000000000000
```

---

## Add IAS42 to MetaMask

1. MetaMask → **Import tokens** → **Custom token**
2. Token contract address: *(paste iassafe42 address)*
3. Symbol `IAS42` and decimals `18` fill in automatically
4. Click **Add custom token** → **Import tokens**

