# iassafe42 (IAS42) — Project Whitepaper

## 1. What is this project?

**iassafe42** is a fungible digital token built on the Ethereum blockchain as part of
the 42 School *Tokenizer* project. The goal is to demonstrate the full lifecycle of a
token: writing the smart contract, deploying it on a public testnet, and interacting
with it through a block explorer.

The project has two parts:

- **Mandatory** — `iassafe42.sol`: an ERC-20 token named IAS42 with a fixed supply
  of 42,000,000 tokens, deployed on Ethereum Sepolia.
- **Bonus** — `MultiSig42.sol`: a multisignature wallet that controls IAS42 transfers
  and requires at least 2 owner approvals before any transfer executes.

---

## 2. Token Specification

| Property          | Value                          |
|-------------------|-------------------------------|
| Name              | iassafe42                      |
| Symbol / Ticker   | IAS42                          |
| Standard          | ERC-20 (Ethereum)              |
| Network           | Ethereum Sepolia Testnet       |
| Decimals          | 18                             |
| Total Supply      | 42,000,000 IAS42               |
| Minting           | Fixed — minted once at deploy  |
| Contract Address  | *(see README.md)*              |

---

## 3. Architecture

```
┌─────────────────────────────────────────┐
│           Ethereum Sepolia              │
│                                         │
│   ┌──────────────┐   controls   ┌─────────────────┐
│   │  iassafe42   │ ◄─────────── │   MultiSig42    │
│   │  (ERC-20)    │              │  (bonus wallet) │
│   └──────────────┘              └─────────────────┘
│         ▲                            ▲    ▲
│         │ holds tokens               │    │
│   deployer wallet              Owner1  Owner2
└─────────────────────────────────────────┘
```

- `iassafe42` is a standard ERC-20 token — any wallet can send/receive it.
- `MultiSig42` is a smart contract wallet that holds IAS42 tokens and
  only releases them when the required number of owners approve.

---

## 4. Technology Choices

### Blockchain — Ethereum Sepolia
Ethereum has the largest developer ecosystem and the most mature tooling.
Sepolia is its official testnet — free to use, no real money involved.

### Language — Solidity 0.8.20
The native language of the EVM. Version 0.8.20 has built-in overflow protection
and is fully supported by OpenZeppelin v5 and Remix IDE.

### Library — OpenZeppelin
Industry-standard audited contracts. The ERC-20 base handles `transfer`,
`approve`, `transferFrom`, balances, and allowances automatically.

### IDE — Remix
Browser-based, no installation, integrates directly with MetaMask.
Perfect for testnet deployments without any local setup.

---

## 5. Security Design

### iassafe42
- Fixed supply — no `mint()` function after construction.
- No owner privileges — deployer has no special power after launch.
- OpenZeppelin base — no custom transfer logic that could introduce bugs.

### MultiSig42
- Threshold enforcement — `require(confirmations >= requiredConfirmations)`.
- Checks-effects-interactions pattern — `executed = true` is set **before**
  calling `token.transfer()`, preventing re-entrancy.
- No duplicate owners — constructor rejects duplicate addresses.
- Zero-address guards — both contracts reject `address(0)`.
- Immutable token reference — `token` is `immutable`, cannot be changed after deploy.

---

## 6. File Structure

```
code/
  iassafe42.sol       ERC-20 token
  MultiSig42.sol      Multisig wallet (bonus)

deployment/
  deploy_notes.md       Step-by-step deployment instructions
  remix_deployment.md   Remix IDE deployment record and tool explanation

documentation/
  whitepaper.md       This file — general overview
  iassafe42_guide.md  All token functions, deploy steps, live usage
  MultiSig42_guide.md Multisig workflow, functions, security
```
