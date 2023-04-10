// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


// The ADORETHEALL project collects 10,000 NFT.
// which is the only way to authenticate "ATA CLUB" members.
// The club is dedicated to bringing together people who are creative, adventurous and yearn for freedom. 
// In the future, Club members will launch a series of offline activities for club members to participate in.
// EXPECT !!!
// @auther yichenglee
// @title  adorethall
contract Adoretheall is ERC721A, Ownable, ReentrancyGuard{

    using SafeMath for uint256;
    using MerkleProof for bytes32[];
    uint public constant MAX_SUPPLY = 10;
    uint public constant SALE_PRICE = 0.0001 ether;
    uint public constant MAX_PER_MINT = 2;
    bool public initiated = false;
    bool public revealed = false;
    string public baseTokenURI;
    bytes32 public merkleRoot; // Root hashing after whitelist generation merkle tree. To verify WL

    constructor(string memory baseURI, string memory name, string memory symbol) ERC721A(name, symbol) {
        setBaseURI(baseURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setMerkleRoot(bytes32 _merkleRootHash) external onlyOwner
    {
        merkleRoot = _merkleRootHash;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function initiate(bool _initiate) public onlyOwner {
        initiated = _initiate;
    } 

    function reveal() public onlyOwner {
        revealed = true;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    /**
     * @notice  genesis NFT and allocations to developers 
     *          Reserve 5%
     */
    function genesisNFT() public onlyOwner {
        require(totalSupply().add(MAX_SUPPLY.mul(5).div(100)) <= MAX_SUPPLY, "Genesis NFT ERROR!");
        _mint(msg.sender, MAX_SUPPLY.mul(5).div(100));
        initiate(true);        
    }

    /**
     * @notice  The address of the distributed server where the tokens are stored
     * @param   tokenId id of the token to be queried
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert URIQueryForNonexistentToken();
        }
        string memory baseURI = _baseURI();
        string memory isRevealed = !revealed ? 'unRevealed' : _toString(tokenId);
        string memory result = string(abi.encodePacked(baseURI, isRevealed, '.json'));
        return bytes(baseURI).length != 0 ? result : '';
    }
    
    /**
     * @notice  verify address by merlkle tree
     */
    function verifyAddress(bytes32[] calldata _merkleProof) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }

    /**
     * @notice  public sale call entry used to cast nft
     */
    function mintNFTS(uint256 _quantity) external payable callerIsUser{
        require(initiated, "This collection is not start");
        require(totalSupply().add(_quantity) <= MAX_SUPPLY, "This collection is sold out!");
        require(_quantity >0 && _quantity <= MAX_PER_MINT, "You have received the maximum amount of NFTs allowed.");
        require(msg.value >= SALE_PRICE.mul(_quantity), "Not enough ether to purchase NFTs.");
        uint256 totalCost = SALE_PRICE.mul(_quantity);
        _mint(msg.sender, _quantity);
        refundIfOver(totalCost);

    }

    /**
     * @notice  The whitelist call entry is used to cast nft
     */
    function wlMintNFTS(bytes32[] calldata _merkleProof, uint256 _quantity) external payable callerIsUser{
        require(verifyAddress(_merkleProof), "You are not in the WL");
        require(initiated, "This collection is not start");
        require(totalSupply().add(_quantity) <= MAX_SUPPLY, "The wl has been used up!");
        require(_quantity >0 && _quantity <= MAX_PER_MINT, "You have received the maximum amount of NFTs allowed.");
        _mint(msg.sender, _quantity);
    }

    /**
     * @notice  If users pay more Ether, they need to be refunded.
     */
    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function withdraw() public onlyOwner nonReentrant {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}