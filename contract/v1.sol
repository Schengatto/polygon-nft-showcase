// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable{

   using Counters for Counters.Counter;
   Counters.Counter public currentTokenId;

   string public baseTokenURI;
   
   constructor() ERC721("SchengattoNFT", "SCH") Ownable(msg.sender){
        baseTokenURI = "";
   }

   function mintNFT() public returns (uint256) {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(msg.sender, newItemId);
        return newItemId;
   }

   function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
   }

   function setBaseTokenURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
   }
}