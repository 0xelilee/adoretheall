//SPDX-License-Identifier: MIT
//NAME: Adoretheall
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "erc721a/contracts/ERC721A.sol";


contract Adoretheall is ERC721A, Ownable {

    using SafeMath for uint256;
    using Counters for Counters.Counter;

    uint public constant MAX_SUPPLY = 20;
    uint public constant PRICE = 0.0001 ether;
    uint public constant MAX_PER_MINT = 1;
    bool public paused = true;
    bool public revealed =true;
    string public baseTokenURI;
    string public hiddenTokenURI;
    Counters.Counter private _tokenIds;

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is a contract account");
        _;
    }

    constructor(string memory baseURI, string memory hiddenURI, string memory name, string memory symbol) ERC721A(name, symbol) {
        setBaseURI(baseURI, hiddenURI);
    }

    function setBaseURI(string memory _baseTokenURI, string memory _hiddenTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
        hiddenTokenURI = _hiddenTokenURI;
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

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }

    function withdraw() public onlyOwner nonReentrant {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    //如果超过退款
    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }
}