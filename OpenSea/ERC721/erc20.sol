// Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//define contract parameters here
contract XZMeta is ERC20, Ownable {
    using Strings for uint256;

    //Toggle to start sale
    bool public _isSaleActive = false;

    //Toggle to enble token display
    bool public _revealed = false;

    //Maximum supply
    uint256 public constant MAX_SUPPLY = 10;

    //Mint price
    uint256 public mintPrice = 0.3 ether;

    //Maximum no. of tokens for each wallet address
    uint256 public maxBalance = 1;

    //Maximum mint no. of for each wallet address
    uint256 public maxMint = 1;

    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";

    mapping(uint256 => string) private _tokenURIs;

    //Entry point
    constructor(string memory initBaseURI, string memory initNotRevealedUri)
        ERC20("XZ Meta", "XZM")
    {
        setBaseURI(initBaseURI);
        setNotRevealedURI(initNotRevealedUri);
    }

    //Function called to mint
    function mintXZMeta(uint256 tokenQuantity) public payable {
        //Run out of supply
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        //Before activating sale
        require(_isSaleActive, "Sale must be active to mint XZMetas");
        //Buyer wallet token quantity + purchase quantity exceeds max allowable
        require(
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        //Not enough funds in buyer wallet
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ETH"
        );
        //Buiyer wallet already has token minted
        require(tokenQuantity <= maxMint, "Can only mint 1 token at a time");

        //All pass, proceed to mint
        _mintXZMeta(tokenQuantity);
    }

    function _mintXZMeta(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _mint(msg.sender, mintIndex);
            }
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        returns (string memory)
    {
        //no exists in erc20?
        // require(
        //     _exists(tokenId),
        //     "ERC721Metadata: URI query for nonexistent token"
        // );

        if (_revealed == false) {
            return notRevealedUri;
        }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    // internal
    function _baseURI() internal view virtual returns (string memory) {
        return baseURI;
    }

    //************************ For Owner Use ***************************/
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}