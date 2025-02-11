// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
contract MyContractProxy is ERC1967Proxy {
    constructor(address _logic, address initialOwner, address _tokenAddress, address _nftAddress)
        ERC1967Proxy(_logic, abi.encodeWithSignature("initialize(address,address,address)", initialOwner, _tokenAddress, _nftAddress))
    {}
}
