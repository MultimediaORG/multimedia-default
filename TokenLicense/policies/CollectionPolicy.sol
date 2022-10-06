// SPDX-License-Identifier: AGPL-3.0-only
// Proxy Redemption is a contract that redeems votes for treasury assets

pragma solidity ^0.8.15;

import {ERC20} from '@rari-capital/solmate/src/tokens/ERC20.sol';
import { INFT, CollectionMeta, CollectionRepository, CollectionMetaPublish } from "../modules/CLCTN.sol";
import { Kernel, Policy, Permissions, Keycode } from "../Kernel.sol";
import { toKeycode } from "../utils/KernelUtils.sol";

contract CollectionPolicy is Policy {
    /////////////////////////////////////////////////////////////////////////////////
    //                         Kernel Policy Configuration                         //
    /////////////////////////////////////////////////////////////////////////////////


    CollectionRepository public CLCTN;

    constructor(Kernel kernel_) Policy(kernel_) {}

    function configureDependencies() external override onlyKernel returns (Keycode[] memory dependencies) {
        dependencies = new Keycode[](1);

        dependencies[0] = toKeycode("CLCTN");
        CLCTN = CollectionRepository(getModuleAddress(toKeycode("CLCTN")));
    }

    function requestPermissions() external view override onlyKernel returns (Permissions[] memory requests) {
        requests = new Permissions[](1);
        requests[0] = Permissions(toKeycode("CLCTN"), CLCTN.publish.selector);
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
        CollectionMetaPublish memory metadata
    ) external {
        if (isCollectionOwner(msg.sender, contractAddress))
            CLCTN.publish(msg.sender, contractAddress, metadata);
    }

    function getCollection(
      uint256 chainId_,
      address contractAddress
    ) public view returns (CollectionMeta memory metadata) {
      return CLCTN.getCollection(chainId_, contractAddress);
    }
}