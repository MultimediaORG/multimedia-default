// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.15;

import { CollectionMeta, CollectionRepository, CollectionMetaPublish } from "../modules/CLCTN.sol";
import { CollectionMetaV2, CollectionRepositoryV2, CollectionMetaPublishV2 } from "../modules/CLCTA.sol";
import { Kernel, Policy, Permissions, Keycode } from "../Kernel.sol";
import { toKeycode } from "../utils/KernelUtils.sol";
import { INFT } from "../../Interfaces/INFT.sol";

contract CollectionPolicyV2 is Policy {
    /////////////////////////////////////////////////////////////////////////////////
    //                         Kernel Policy Configuration                         //
    /////////////////////////////////////////////////////////////////////////////////


    CollectionRepository public CLCTN;
    CollectionRepositoryV2 public CLCTA;

    constructor(Kernel kernel_) Policy(kernel_) {}

    function configureDependencies() external override onlyKernel returns (Keycode[] memory dependencies) {
        dependencies = new Keycode[](2);

        dependencies[0] = toKeycode("CLCTN");
        CLCTN = CollectionRepository(getModuleAddress(toKeycode("CLCTN")));
        dependencies[1] = toKeycode("CLCTA");
        CLCTA = CollectionRepositoryV2(getModuleAddress(toKeycode("CLCTA")));
    }

    function requestPermissions() external view override onlyKernel returns (Permissions[] memory requests) {
        requests = new Permissions[](2);
        requests[0] = Permissions(toKeycode("CLCTN"), CLCTN.publish.selector);
        requests[1] = Permissions(toKeycode("CLCTA"), CLCTA.publish.selector);
    }


    /////////////////////////////////////////////////////////////////////////////////
    //                                Policy Variables                             //
    /////////////////////////////////////////////////////////////////////////////////

    function isCollectionOwner(
        address owner,
        address tokenAddress
    ) internal view returns (bool isOwner) {
        try INFT(tokenAddress).owner() returns (address creator) {
        if (creator == owner) return true;
            return false;
        } catch {
            return false;
        }
    }

    function publish(
        address contractAddress,
        CollectionMetaPublish memory metadata,
        CollectionMetaPublishV2 memory metadataV2
    ) external {
        if (isCollectionOwner(msg.sender, contractAddress)) {
            CLCTN.publish(msg.sender, contractAddress, metadata);
            CLCTA.publish(contractAddress, metadataV2);
        }
    }

    function getCollection(
      uint256 chainId_,
      address contractAddress
    ) public view returns (CollectionMetaV2 memory metadata) {
        CollectionMeta memory collectionMeta = CLCTN.getCollection(chainId_, contractAddress);
        CollectionMetaPublishV2 memory collectionMetaV2 = CLCTA.getCollection(chainId_, contractAddress);

        return CollectionMetaV2({
            owner: collectionMeta.owner,
            name: collectionMeta.name,
            symbol: collectionMeta.symbol,
            primaryImage: collectionMeta.primaryImage,
            bannerImage: collectionMeta.bannerImage,
            category: collectionMeta.category,
            title: collectionMeta.title,
            description: collectionMeta.description,
            saleFeeRecipient: collectionMeta.saleFeeRecipient,
            saleFeeBps: collectionMeta.saleFeeBps,
            creatorAddresses: collectionMeta.creatorAddresses,
            externalLinks: collectionMeta.externalLinks,
            creatorTags: collectionMeta.creatorTags,
            assets: collectionMeta.assets,
            isCopyrighted: collectionMetaV2.isCopyrighted,
            isExpired: collectionMetaV2.isExpired
        });
    }
}