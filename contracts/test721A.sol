// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract adore is ERC721A, Ownable, ReentrancyGuard{

    using SafeMath for uint256;
    uint public constant MAX_SUPPLY = 10;
    uint public constant PRICE = 0.0001 ether;
    uint public constant MAX_PER_MINT = 2;
    bool public paused = true;
    bool public revealed =true;
    string public baseTokenURI;
    string public hiddenTokenURI;

    constructor(string memory baseURI, string memory hiddenURI, string memory name, string memory symbol) ERC721A(name, symbol) {
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

    function mint(uint256 _quantity) external payable {
        require(!paused, "This collection is not start");
        require(totalSupply().add(_quantity) <= MAX_SUPPLY, "This collection is sold out!");
        require(_quantity >0 && _quantity <= MAX_PER_MINT, "You have received the maximum amount of NFTs allowed.");
        require(msg.value >= PRICE.mul(_quantity), "Not enough ether to purchase NFTs.");
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, _quantity);
    }

    function withdraw() public onlyOwner nonReentrant {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}