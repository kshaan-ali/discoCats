# TimeVaultV1

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.22-363636.svg?logo=solidity)

## 📌 Overview
TimeVaultV1 is a smart contract designed for decentralized token vault management, supporting ERC20 tokens and ERC721 NFTs. It enables users to join a vault, deposit tokens, claim NFTs, and withdraw funds after predefined time periods.

## 🚀 Features
- **Upgradeable** using UUPS proxy pattern
- **Ownable** contract with administrative control
- **Reentrancy protected** to ensure secure transactions
- **NFT minting & burning** for vault participants
- **Time-based vault states** (Joining, Claiming, Withdrawable)
- **Yield tracking** for deposited funds

## 🔧 Installation
To deploy and interact with TimeVaultV1, ensure you have:

```bash
npm install
```

or if using Yarn:

```bash
yarn install
```

## 📜 Smart Contracts
### `TimeVaultV1.sol`
The main vault contract with functionalities:
```solidity
function joinVault(uint256 _nftAmount) public;
function withdrawAllFunds(address receiver) public onlyOwner;
function claimBack() public nonReentrant;
function setTimePeriod(uint256 _joiningPeriod, uint256 _claimingPeriod) public onlyOwner;
```

### `TimeNft.sol`
An ERC721 NFT contract for tracking vault participation.
```solidity
function safeMint(address to, uint256 amount) public;
function burn(uint256 tokenId) public;
```

### `MyContractProxy.sol`
A proxy contract for upgradeability:
```solidity
constructor(
    address _logic,
    uint256 _nftPrice,
    uint256 _nftLimitPerAddress,
    address initialOwner,
    address _tokenAddress,
    uint256 _nftLimit,
    uint256 _joiningPeriod,
    uint256 _claimingPeriod
) ERC1967Proxy(...)
```

## 📖 Usage
1. **Deploy the contracts** using a Solidity-compatible environment.
2. **Set the vault parameters** (token address, limits, and periods).
3. **Users can join the vault** by depositing tokens.
4. **Claim back funds & NFTs** after the claiming period.

## 🛠 Built With
- Solidity `^0.8.22`
- OpenZeppelin Contracts `^5.0.0`
- Hardhat / Foundry (for development & testing)

## 📝 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---


