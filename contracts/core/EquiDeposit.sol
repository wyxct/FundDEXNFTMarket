// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Errors } from "../interfaces/Errors.sol";

contract EquiDeposit is ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable{

    string private Name;
    uint private PRICE = 1 ether;
    address private EquiRaise;
    
    constructor(){
        _disableInitializers();
    }

    modifier onlyEquiRaise {
        require(msg.sender == EquiRaise, "not EquiRaise");
        _;
    }

    function initialize(string memory name, string memory symbol, address _equiraise) public initializer {
        __ERC20_init(name,symbol);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        EquiRaise = _equiraise;
    }

    function ChangeEquiRaise(address _equiraise) public onlyOwner{
        EquiRaise = _equiraise;
    }

    function getToken(uint amount, uint expect_num) public{
        if (amount/PRICE < expect_num) revert Errors.NeedTokenNumError(amount/PRICE, expect_num);
        _mint(msg.sender,amount/PRICE);
    }


    function _authorizeUpgrade(address) internal override onlyOwner {}

}