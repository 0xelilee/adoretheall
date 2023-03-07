//SPDX-License-Identifier: MIT
//NAME: Adoretheall_club
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Adoretheall is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    uint public constant MAX_SUPPLY = 20;
    uint public constant PRICE = 0.0001 ether;
    uint public constant MAX_PER_MINT = 1;
    bool public paused = true;
    bool public revealed =true;
    string public baseTokenURI;
    string public hiddenTokenURI;

    constructor(string memory baseURI, string memory hiddenURI, string memory name, string memory symbol) ERC721(name, symbol) {
        setBaseURI(baseURI, hiddenURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        if(revealed == true){
            return hiddenTokenURI;
        }else{
            return baseTokenURI;
        }
    }

    function setBaseURI(string memory _baseTokenURI, string memory _hiddenTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
        hiddenTokenURI = _hiddenTokenURI;
    }

    function pause(bool _paused) public onlyOwner {
        paused = _paused;
    } 

    function reveal(bool _reveal) public onlyOwner {
        revealed = _reveal;
    }

    function mintNFTs(uint _count) public payable {

        uint totalMinted = _tokenIds.current();
        require(!paused, "This collection is not start");
        require(totalMinted.add(_count) <= MAX_SUPPLY, "This collection is sold out!");
        require(_count >0 && _count <= MAX_PER_MINT, "You have received the maximum amount of NFTs allowed.");
        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs.");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }

    function _mintSingleNFT() private {
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIds.increment();
    }
    
    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }
    
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    function reserveNFTs(uint _count) public onlyOwner {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(_count) < MAX_SUPPLY, "Not enough NFTs left to reserve");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }
}

