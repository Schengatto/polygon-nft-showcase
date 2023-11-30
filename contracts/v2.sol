// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract SchengattoMarketplace is ERC721URIStorage {

   using Counters for Counters.Counter;
   Counters.Counter public _tokenIds;
   Counters.Counter private _itemsSold;

   string public baseTokenURI;

   uint256 listingPrice = 0;
   address payable owner;

   mapping(uint256 => MarketItem) private idToMarketItem;

   struct MarketItemAttributes {
      uint8 backend;
      uint8 frontend;
      uint8 leadership;
   }

   struct MarketItem {
      uint256 tokenId;
      string name;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
      string tokenURI;
      MarketItemAttributes attributes;
   }

   event MarketItemCreated (
      uint256 indexed tokenId,
      string name,
      address seller,
      address owner,
      uint256 price,
      bool sold,
      string tokenURI,
      MarketItemAttributes attributes
   );

   constructor() ERC721("Schengatto NFT", "SCH") {
        owner = payable (msg.sender);
   }

  /* Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable {
      require(owner == msg.sender, "Only marketplace owner can update listing price.");
      listingPrice = _listingPrice;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
      return listingPrice;
    }

    /* Mints a token and lists it in the marketplace */
    function createToken(string memory tokenURI, string memory name, uint256 price, uint8 backend, uint8 frontend, uint8 leadership) public payable returns (uint) {
      _tokenIds.increment();
      uint256 newTokenId = _tokenIds.current();

      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      createMarketItem(newTokenId, price, name, backend, frontend, leadership);
      return newTokenId;
    }

    function createMarketItem(
      uint256 tokenId,
      uint256 price,
      string memory name,
      uint8 backend,
      uint8 frontend,
      uint8 leadership
    ) private {
      require(msg.value == listingPrice, "Price must be equal to listing price");
      require(backend < 10, "backend must be between 0 and 10");
      require(frontend < 10, "frontend must be between 0 and 10");
      require(leadership < 10, "leadership must be between 0 and 10");

      idToMarketItem[tokenId] =  MarketItem(
        tokenId,
        name,
        payable(msg.sender),
        payable(address(this)),
        price,
        false,
        tokenURI(tokenId),
        MarketItemAttributes(backend, frontend, leadership)
      );

      _transfer(msg.sender, address(this), tokenId);
      emit MarketItemCreated(
        tokenId,
        name,
        msg.sender,
        address(this),
        price,
        false,
        tokenURI(tokenId),
        MarketItemAttributes(backend, frontend, leadership)
      );
    }

    /* allows someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price) public payable {
      require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
      require(msg.value == listingPrice, "Price must be equal to listing price");
      idToMarketItem[tokenId].sold = false;
      idToMarketItem[tokenId].price = price;
      idToMarketItem[tokenId].seller = payable(msg.sender);
      idToMarketItem[tokenId].owner = payable(address(this));
      _itemsSold.decrement();

      _transfer(msg.sender, address(this), tokenId);
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(
      uint256 tokenId
      ) public payable {
      uint price = idToMarketItem[tokenId].price;
      address seller = idToMarketItem[tokenId].seller;
      require(msg.value == price, "Please submit the asking price in order to complete the purchase");
      idToMarketItem[tokenId].owner = payable(msg.sender);
      idToMarketItem[tokenId].sold = true;
      idToMarketItem[tokenId].seller = payable(address(0));
      _itemsSold.increment();
      _transfer(address(this), msg.sender, tokenId);
      payable(owner).transfer(listingPrice);
      payable(seller).transfer(msg.value);
    }

     /* Returns all items */
    function fetchAlltems() public view returns (MarketItem[] memory) {
      uint itemCount = _tokenIds.current();
      uint currentIndex = 0;

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < itemCount; i++) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
      return items;
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
      uint itemCount = _tokenIds.current();
      uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
      uint currentIndex = 0;

      MarketItem[] memory items = new MarketItem[](unsoldItemCount);
      for (uint i = 0; i < itemCount; i++) {
        if (idToMarketItem[i + 1].owner == address(this)) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items a user has listed */
    function fetchItemsListed() public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

}