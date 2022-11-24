// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.9;
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address private owner;
    using Strings for uint256;
    uint256 public cost = 0.05 ether;
    constructor() ERC721("NFT", "NFT") {
        owner = msg.sender;
    }

    function awardItem(string memory tokenURI)
        public
        payable
        returns (uint256)
    {
        require(msg.value == cost,"not enough eth");

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }
}
