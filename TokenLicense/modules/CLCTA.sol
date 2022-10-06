// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.15;

import { Kernel, Module, Keycode } from "../Kernel.sol";

import { CollectionMetaV2, CollectionMetaPublishV2 } from "../schema/CollectionSchemaV2.sol";

contract CollectionRepositoryV2 is Module {

    // ChainID => Contract Address => CollectionMeta
    uint256 chainId;
    mapping (uint256 => mapping (address => CollectionMetaPublishV2)) collections;
    // ChainID => Contract Address => Token ID => TokenMeta
    // mapping (uint256 => mapping (address => mapping (uint256 => TokenMeta))) tokens;

    constructor(Kernel kernel_, uint256 chainId_) Module(kernel_) {
      chainId = chainId_;
    }

    function KEYCODE() public pure override returns (Keycode) {
      return Keycode.wrap("CLCTA");
    }

    /// @inheritdoc Module
    function VERSION() external pure override returns (uint8 major, uint8 minor) {
      return (2, 0);
    }

    function publish(
      address contractAddress,
      CollectionMetaPublishV2 memory publishV2
    ) public permissioned {
      collections[chainId][contractAddress] = CollectionMetaPublishV2({
        isCopyrighted: publishV2.isCopyrighted,
        isExpired: publishV2.isExpired
      });
    }

    function getCollection(
      uint256 chainId_,
      address contractAddress
    ) public view returns (CollectionMetaPublishV2 memory metadata) {
      return collections[chainId_][contractAddress];
    }
}
