// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.2/security/Pausable.sol";
import "@openzeppelin/contracts@4.7.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.2/utils/Counters.sol";

contract TicketsToken is ERC721, Pausable, Ownable {
    using Counters for Counters.Counter;

    //Maximum quantity of tokens per sale
    uint8 public maxPerSale;
    // Maximum quantity of token types
    uint256 public maxTokenTypes;
    // Maximum quantity of tokens to be minted per each tokenType
    uint256[] public caps;
    // Rate in Wei per each tokenType
    uint256[] public rates;
    //Counter of minted tokens for each tokenType
    mapping (uint256 => uint256) public totals;
    //mapping of token type for each token ID
    mapping (uint256 => uint256) public types;

    //saleToken event
    event saleTokenSuccess (
        uint256 quantity,
        uint256 tokenType,
        address owner
    );

    //courtesyToken event
    event courtesyTokenSuccess (
        uint256 quantity,
        uint256 tokenType,
        address owner
    );

    Counters.Counter private _tokenIdCounter;

    constructor(string memory _name, string memory _symbol, uint256[] memory _caps, uint256[] memory _rates, uint8 _maxPerSale) ERC721(_name, _symbol) { 
            //revert if caps or rates are not correctly defined
            require(_caps.length == _rates.length, 'invalidCapsRatesLength');
            //revert if _maxPerSale is 0
            require(_maxPerSale > 0, 'invalidMaxPerSale');
            for (uint256 i = 0; i < _caps.length; i++ ){
                //revert if either cap or rate is 0 for any type of token
                require(_caps[i] > 0 && _rates[i] > 0, 'invalidCapRate');
            }
            maxTokenTypes = _caps.length;
            caps = _caps;
            rates = _rates;
            maxPerSale = _maxPerSale;
        }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    //Mint & send _quantity ERC721 tokens to msg.sender if conditions are met
    function buyToken(uint256 _tokenType, uint256 _quantity) public payable {
        //revert if _quantity is 0
        require(_quantity > 0, 'invalidQuantity');
        //revert if _tokenType is invalid
        require(_tokenType < maxTokenTypes, 'invalidTokenType');
        //revert if _quantity is more than maximum allowed per sale
        require(_quantity <= maxPerSale, 'quantityOverMax');

        uint256 amountToPay = _quantity * rates[_tokenType];
        uint256 supplyIfMinted = totals[_tokenType] + _quantity;
        //revert if msg.value doesn't match amount of purchase
        require(msg.value >= amountToPay, 'amountNotEnough');
        //revert if cap is reached
        require( supplyIfMinted <= caps[_tokenType], 'soldOut');
        //mint all tokens if all conditions are met
        for (uint8 i = 0; i < _quantity; i++) {
            safeMint(msg.sender, _tokenType);
            if (i == _quantity - 1) {
                emit saleTokenSuccess(_quantity, _tokenType, msg.sender);
            }
        }
        // Refund excedent amount
        uint256 toRefund = msg.value - amountToPay;
        payable(msg.sender).transfer(toRefund);

        // Send ethers to contract owner
        payable(owner()).transfer(amountToPay);
    }

    //mint & send _quantity ERC721 tokens to _to as ordered by the owner if conditions are met
    function courtesyToken(uint256 _tokenType, uint256 _quantity, address _to) public onlyOwner {
        //revert if _quantity is 0
        require(_quantity > 0, 'invalidQuantity');
        //revert if _tokenType is invalid
        require(_tokenType < maxTokenTypes, 'invalidTokenType');        
        uint256 supplyIfMinted = totals[_tokenType] + _quantity;
        //revert if cap is reached
        require( supplyIfMinted <= caps[_tokenType], 'soldOut');
        //mint all tokens if all conditions are met
        for (uint8 i = 0; i < _quantity; i++) {
            safeMint(_to, _tokenType);
            if (i == _quantity - 1) {
                emit courtesyTokenSuccess(_quantity, _tokenType, _to);
            }
        }
    }

    function safeMint(address to, uint _tokenType) private onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        // Update counter of tokens for this specific type
        totals[_tokenType]++;
        // Record token type for this token id
        types[tokenId] = _tokenType;
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
