// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.15;

import { Kernel, Module, Keycode } from "../Kernel.sol";

import { CollectionMeta, CollectionMetaPublish } from "../schema/CollectionSchema.sol";

import { INFT } from "../../Interfaces/INFT.sol";

contract CollectionRepository is Module {

    // ChainID => Contract Address => CollectionMeta
    uint256 chainId;
    mapping (uint256 => mapping (address => CollectionMeta)) collections;
    // ChainID => Contract Address => Token ID => TokenMeta
    // mapping (uint256 => mapping (address => mapping (uint256 => TokenMeta))) tokens;

    constructor(Kernel kernel_, uint256 chainId_) Module(kernel_) {
      chainId = chainId_;
    }

    function KEYCODE() public pure override returns (Keycode) {
      return Keycode.wrap("CLCTN");
    }

    /// @inheritdoc Module
    function VERSION() external pure override returns (uint8 major, uint8 minor) {
      return (1, 0);
    }


    function publish(
      address owner,
      address contractAddress,
      CollectionMetaPublish memory metadata
    ) public permissioned {
      collections[chainId][contractAddress] = CollectionMeta({
        owner: owner,
        name: INFT(contractAddress).name(),
        symbol: INFT(contractAddress).symbol(),
        primaryImage: metadata.primaryImage,
        bannerImage: metadata.bannerImage,
        category: metadata.category,
        title: metadata.title,
        description: metadata.description,
        saleFeeRecipient: metadata.saleFeeRecipient,
        saleFeeBps: metadata.saleFeeBps,
        creatorAddresses: metadata.creatorAddresses,
        externalLinks: metadata.externalLinks,
        creatorTags: metadata.creatorTags,
        assets: metadata.assets
      });
    }

    function getCollection(
      uint256 chainId_,
      address contractAddress
    ) public view returns (CollectionMeta memory metadata) {
      return collections[chainId_][contractAddress];
    }
}
