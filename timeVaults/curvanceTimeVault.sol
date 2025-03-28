// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
//Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable


import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract NativeTimeVault is ERC721, ERC721Enumerable, Ownable, ReentrancyGuard {
    // Vault state variables...
    uint256 public tokenIdCounter = 0;
    string private _baseTokenURI;
    
    constructor(address initialOwner) ERC721("TimeNft", "TNFT") Ownable(initialOwner) {
        // Initialization...
        _baseTokenURI = "https://...";
    }
    
    // Keep all your existing vault functions...
    
    // Add NFT functions directly:
    function safeMint(address to, uint256 amount) internal {
        require(nftLimit >= tokenIdCounter + amount, "Exceeds limit");
        for (uint256 i = 0; i < amount; i++) {
            tokenIdCounter++;
            _safeMint(to, tokenIdCounter);
        }
    }
    
    // Override required ERC721 functions...
    function _update() internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update();
    }
    
    // Other overrides...
}