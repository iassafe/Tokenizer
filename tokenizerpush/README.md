# iassafe42 (IAS42) — Tokenizer Project

## Repository Structure

```
.
├── README.md
├── code/
│   ├── iassafe42.sol          # ERC-20 token contract (mandatory)
│   └── MultiSig42.sol         # Multisignature wallet contract (bonus)
├── deployment/
│   ├── deploy_notes.md        # Step-by-step deployment guide
│   └── remix_deployment.md    # Remix IDE deployment record and tool explanation
└── documentation/
    ├── whitepaper.md           # General project overview
    ├── iassafe42_guide.md      # Token: all functions, deploy steps, usage
    └── MultiSig42_guide.md     # Multisig: workflow, all functions, security
```

---

## Blockchain Platform Choice — Ethereum (Sepolia Testnet)

**Why Ethereum?**

Ethereum is the most mature and widely adopted smart-contract blockchain in the world.
It has the largest developer ecosystem, the most complete tooling (Remix,
OpenZeppelin, Etherscan), and the most documentation available — making it the best
choice for learning and demonstrating token creation.

Sepolia is the official Ethereum proof-of-stake testnet recommended since 2023. It
replaced deprecated testnets (Ropsten, Rinkeby, Goerli) and is fully supported by
Remix, MetaMask, and Etherscan. No real money is required.

**Why not BNB Chain?**

BNB Chain uses the BEP-20 standard, which is functionally identical to ERC-20 — the
Solidity code would be the same. Ethereum Sepolia was preferred because its tooling
(Etherscan, faucets, Remix integration) is more stable and better documented for
educational purposes.

---

## Language Choice — Solidity ^0.8.20

**Why Solidity?**

Solidity is the native programming language of the Ethereum Virtual Machine (EVM).
It is the only language that can be used to write ERC-20 contracts deployed directly
on Ethereum. No other choice is possible for this platform.

**Why version 0.8.20?**

- Built-in integer overflow/underflow protection (no need for SafeMath library).
- Latest stable release fully supported by OpenZeppelin v5.
- Supported by Remix IDE 2.2.0 without any extra configuration.

**Why OpenZeppelin?**

OpenZeppelin provides a battle-tested, widely audited implementation of the ERC-20
standard. Using it avoids re-implementing security-critical logic from scratch and
guarantees compatibility with all wallets, explorers, and DeFi protocols.

---

## Token — iassafe42 (IAS42)

| Property          | Value                             |
|-------------------|-----------------------------------|
| Name              | iassafe42                         |
| Symbol / Ticker   | **IAS42**                         |
| Standard          | ERC-20                            |
| Network           | Ethereum Sepolia Testnet          |
| Total Supply      | 42,000,000 IAS42                  |
| Decimals          | 18                                |
| Contract Address  | *(paste after deployment)*        |

Explorer link:
```
https://sepolia.etherscan.io/token/<contract_address>
```

---

## Bonus — MultiSig42

A multisignature wallet contract (`MultiSig42.sol`) is provided as the bonus part.
It controls IAS42 token transfers and requires at least **2 owner approvals** before
any transfer executes, preventing a single compromised wallet from moving funds.

MultiSig42 contract address: *(paste after deployment)*

Explorer link:
```
https://sepolia.etherscan.io/address/<multisig_address>
```

---

## Development Tools

| Tool                     | Purpose                                          |
|--------------------------|--------------------------------------------------|
| Remix IDE 2.2.0          | Browser-based compiler, deployer, and debugger   |
| MetaMask                 | Wallet — signs all transactions locally          |
| OpenZeppelin 5.x         | Audited ERC-20 base contract                     |
| Sepolia Etherscan        | Block explorer — verify contracts and txs        |
| Google Cloud Web3 Faucet | Free SepoliaETH for gas fees                     |

---

## Security

- **No real money** — Sepolia testnet only. SepoliaETH has zero monetary value.
- **No API keys or passwords** are stored anywhere in this repository.
- All transactions are signed locally by MetaMask — private keys never leave the browser.
- The token name contains **42** as required by the project specification.
