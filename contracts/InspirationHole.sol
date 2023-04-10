// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
  * @author YICHENG LEE
  * @title  This is a contract dedicated to selling works for an artist. Th-
  *         is artist is a very famous traveler and painter. He inspires hi-
  *         mself through travel, and then expresses him through paintingand 
  *         sells it in the form of NFT. I hope everyone likes it.
  */
contract  InspirationHole is ERC721A, Ownable{

    uint public MAX_SUPPLY = 10;
    string public baseTokenURI;

    constructor(string memory baseURI, string memory name, string memory symbol) ERC721A(name, symbol) {
        setBaseURI(baseURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setMAX_SUPPLY(uint256 _MAX_SUPPLY) public onlyOwner{
        MAX_SUPPLY = _MAX_SUPPLY;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    /**
      * NOTICE Only artistic creators can mint NFTs
      */
    function createNFTs(uint256 _quantity) public onlyOwner {
        require(totalSupply() + _quantity <= MAX_SUPPLY, "No more artwork yet!");
        _mint(msg.sender, _quantity);
    }

    /**
      * NOTICE TokenId id of the token to be queried
      */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert URIQueryForNonexistentToken();
        }
        string memory baseURI = _baseURI();
        string memory result = string(abi.encodePacked(baseURI, _toString(tokenId), '.json'));
        return bytes(baseURI).length != 0 ? result : '';
    }

    /**
      * NOTICE  This contract does not allow transfer ownership to a 0 address
      */
    function renounceOwnership() public override view onlyOwner {
        revert("This contract does not allow transfer ownership to a 0 address!");
    }
    
    /**
      * NOTICE  Assign contract ownership to another address, for example
      *         from a developer to an artist's address.Or the address to 
      *         transfer from the artist to the working agent.

      * PARAM   _targetAddress  The address that will become the new owner
      *         of the contract.
      */ 
    function assignOwnership(address _targetAddress) public onlyOwner {
        _transferOwnership(_targetAddress);
    }
    

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }


}