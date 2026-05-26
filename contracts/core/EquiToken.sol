// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Errors } from "../interfaces/Errors.sol";

contract EquiToken is ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable{

    string private Name;
    uint private MIN_PRICE = 0.1 ether;
    uint private MAX_PRICE = 0.5 ether;
    uint private discount_num = 50;
    uint private current_num = 0;
    uint private MAX_MINT_NUM = 1000;
    
    constructor(){
        _disableInitializers();
    }

    function initialize(string memory name, string memory symbol) public{
        __ERC20_init(name,symbol);
    }

    function CalCurrentPrice() public view returns(uint){
        if (current_num >= 50){
            return MAX_PRICE;
        }
        uint current_price = ((MAX_PRICE - MIN_PRICE)/50*current_num) + MIN_PRICE;
        return current_price;
    }

    function getToken(uint amount, uint expect_num) public{
        uint current_price = CalCurrentPrice();
        if (amount/current_price < expect_num) revert Errors.NeedTokenNumError(amount/current_price, expect_num);
        MAX_MINT_NUM -= amount/current_price;
        _mint(msg.sender,amount/current_price);
    }


    function _authorizeUpgrade(address) internal override onlyOwner {}

}