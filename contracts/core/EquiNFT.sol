// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Errors } from "../interfaces/Errors.sol";

contract EquiNFT is ERC721Upgradeable,OwnableUpgradeable,UUPSUpgradeable{
    
    string private projectMame;
    string private _symbol = "N";
    string private _name = "NF";
    uint private tokenId;
    uint private MIN_PRICE = 0.1 ether;
    uint private MAX_PRICE = 0.5 ether;
    uint private DescountNum = 50;
    uint private MAX_NUM = 1000;

    constructor(){
        _disableInitializers();
    }

    function initialize() external initializer{
        __ERC721_init(_name,_symbol);
    }

    function CalCurrentPrice() public view returns(uint){
        if (tokenId >= 49){
            return MAX_PRICE;
        }
        uint current_price = ((MAX_PRICE - MIN_PRICE)/50*tokenId) + MIN_PRICE;
        return current_price;
    }

    function getNFT(uint amount, uint expect_num) public returns(uint){
        uint current_price = CalCurrentPrice();
        if (amount/current_price < expect_num) revert Errors.NeedNFTNumError(amount/current_price, expect_num);
        for(uint i=tokenId; i<tokenId + expect_num; i++){
            _mint(msg.sender,i);
            tokenId++;
        }
        return amount - expect_num*current_price;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

}