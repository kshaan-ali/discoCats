// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TimeNft is ERC721, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    string private _baseTokenURI;
    address public vaultAddress;

    constructor(address initialOwner,string memory baseURI,address _vaultAddress)
        ERC721("TimeNft", "TNFT")
        Ownable(initialOwner)
    {
        _baseTokenURI = baseURI;
        vaultAddress=_vaultAddress;
    }
     function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI; 
    }

    function tokenURI(uint256) public view override returns (string memory) {
        return _baseTokenURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to,uint amount) public  {
        require(msg.sender==owner() || msg.sender==vaultAddress,"can mint");
        for (uint i=0; i<amount; i++) 
        {
            
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        }
    }

   

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }
}
