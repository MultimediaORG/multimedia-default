// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.15;

import "./CollectionSchema.sol";

struct CollectionMetaV2 {
  address owner; // Contract controlled
  string name; // Contract controlled
  string symbol; // Contract controlled
  string primaryImage;
  string bannerImage;
  string category;
  string title;
  string description;
  address saleFeeRecipient;
  uint256 saleFeeBps;
  address[] creatorAddresses;
  string[] externalLinks;
  string[] creatorTags;
  string[] assets;
  bool isCopyrighted;
  bool isExpired;
}

struct CollectionMetaPublishV2 {
  bool isCopyrighted;
  bool isExpired;
}