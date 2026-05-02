# Remix IDE Deployment — iassafe42 & MultiSig42

## Deployment Tool — Remix IDE

All contracts were deployed using **Remix IDE**, a browser-based Solidity development
environment that requires zero installation.

```
https://remix.ethereum.org
```

Remix was chosen because:
- It runs entirely in the browser — no local setup needed.
- It integrates directly with MetaMask for transaction signing.
- It includes a built-in Solidity compiler, debugger, and contract interaction panel.
- It is the most widely used tool for testnet deployments and learning.

No private key or API key is stored anywhere — MetaMask signs all transactions
locally inside the browser. Nothing sensitive ever leaves the machine.

---

## Deployed Contracts

| Contract     | Address                    | Network          |
|--------------|----------------------------|------------------|
| `iassafe42`  | *(paste after deployment)* | Ethereum Sepolia |
| `MultiSig42` | *(paste after deployment)* | Ethereum Sepolia |

Explorer base URL: `https://sepolia.etherscan.io`

---

## Deployment Steps

### Step 1 — Connect MetaMask to Sepolia
- Open MetaMask → switch network to **Sepolia Testnet** (Chain ID: 11155111).
- Get free SepoliaETH if needed: https://cloud.google.com/application/web3/faucet/ethereum/sepolia

### Step 2 — Open Remix and load the contracts
- Go to https://remix.ethereum.org
- In the File Explorer, create `iassafe42.sol` and `MultiSig42.sol`
- Paste the source code from the `code/` folder into each file

### Step 3 — Compile
- Solidity Compiler tab → version `0.8.20` → Optimization ON (200 runs)
- Click **Compile** for each file
- Green checkmark ✅ = ready to deploy

### Step 4 — Deploy iassafe42
- Deploy & Run Transactions tab
- Environment: **Injected Provider – MetaMask**
- Contract: `iassafe42`
- Click **Deploy** → confirm in MetaMask
- Copy the contract address from the Remix console

### Step 5 — Deploy MultiSig42
- Contract: `MultiSig42`
- Fill constructor fields:
  - `_token`: iassafe42 contract address
  - `_owners`: `["0xOwner1","0xOwner2"]`
  - `_requiredConfirmations`: `2`
- Click **Deploy** → confirm in MetaMask

### Step 6 — Fund MultiSig42
- Load iassafe42 in Remix using **At Address**
- Call `transfer(MultiSig42Address, 1000000000000000000000)` to send 1000 IAS42

---

## Transaction Record

| Action                     | Tx Hash   | Block     |
|----------------------------|-----------|-----------|
| Deploy `iassafe42`         | *(paste)* | *(paste)* |
| Deploy `MultiSig42`        | *(paste)* | *(paste)* |
| Fund MultiSig42            | *(paste)* | *(paste)* |
| Token transfer demo        | *(paste)* | *(paste)* |
| MultiSig execute demo      | *(paste)* | *(paste)* |
