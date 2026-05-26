// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { Errors } from "../interfaces/Errors.sol";
import "./EquiToken_rewrite.sol";
import "./EquiNFT_rewrite.sol";
import "./EquiDeposit.sol";

contract EquiRaise is UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable{

    // 筹款逻辑
    // 1.用户在规定时间内可根据需要，贡献大于最小数值，小于最大数值的ETH给该合约√
    // 2.在时间到达前，可多次贡献或取回√
    // 3.时间到达后用户不可取回贡献的ETH，但首批购买期过后可选择在不超过充值最大值的状况下充值ETH√
    // 4.用户可根据贡献和充值的ETH数量兑换多种ERC20代币或者多种NFT√
    // 5.合约管理者可在时间到达后分账获取合约ETH，后续充值的ETH也可再次获取√
    // 6.逻辑可升级，整体逻辑分为多个逻辑块，每个独立逻辑需要可独立升级且参数信息需要保留√
    // 7.增加多种ERC20的代币之间的交换，每次交换收取3%的手续费
    // 8.增加NFT代币之间的交换，每次交换收取上架代币的ERC20价值的3%
    // 9.增加ERC20的代币与NFT之间的交换，每次交换收取3%的手续费

    EquiToken private equiToken;
    EquiNFT private equiNFT;
    EquiDeposit private equiDeposit;
    uint private deployTime;
    uint private constant lockTime = 5 minutes;
    uint private constant firstbuyTime = 5 minutes;
    string private projectName;
    uint private MIN_VALUE = 0.5 ether;
    uint private MAX_VALUE = 2 ether;
    uint private Total;
    address private Owner;
    mapping(address => uint) private OwnFundAmount;
    mapping(address => uint) private PriorityMapping;
    address[] private PriorityAddress;
    uint private priorityTotal;


    constructor(){
        _disableInitializers();
    }

    modifier onlyDuringFund(){
        require(block.timestamp <= deployTime + lockTime, "not Fund Time");
        _;
    }

    modifier onlyAfterFund(){
        require(block.timestamp > deployTime + lockTime, "Fund Time");
        _;
    }

    modifier onlyAfterFirstBuy(){
        require(block.timestamp > deployTime + lockTime + firstbuyTime, "First Buy Time");
        _;
    }

    function initialize(string calldata projectname, address _equiToken, address _equiNFT, address _equiDeposit) external initializer{
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Ownable_init(msg.sender);
        equiToken = EquiToken(_equiToken);
        equiNFT = EquiNFT(_equiNFT);
        equiDeposit = EquiDeposit(_equiDeposit);
        Owner = msg.sender;
        deployTime = block.timestamp;
        projectName = projectname;
    }

    function Fund() public payable onlyDuringFund {
        if (msg.value < MIN_VALUE || msg.value > MAX_VALUE) revert Errors.FundAmountError(MIN_VALUE,MAX_VALUE,msg.value);
        Total += msg.value;
        OwnFundAmount[msg.sender] += msg.value;
    }

    function getBalance(address person) public view returns(uint) {
        return OwnFundAmount[person];
    }

    function reFund() public onlyDuringFund nonReentrant {
        if (OwnFundAmount[msg.sender] <= 0) revert Errors.RefundAmountError(OwnFundAmount[msg.sender]);
        uint amount = OwnFundAmount[msg.sender];
        Total -= OwnFundAmount[msg.sender];
        OwnFundAmount[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success, "reFund failed");
        
    }

    function getFund() public onlyOwner onlyAfterFund nonReentrant {
        if (Total<=0) revert Errors.GetFundAmountError(Total);
        uint amount = Total;
        Total = 0;
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success, "getFund failed");
    }

    function insertPriority(address Person, uint priority) public onlyOwner {
        if(Person == address(0)) revert Errors.PersonAddrError(Person);
        if(priority <=0) revert Errors.PriorityError(Person,priority);
        if (PriorityMapping[Person]==0){
            PriorityAddress.push(Person);
        }
        PriorityMapping[Person] += priority;
        priorityTotal += priority;
    }

    function getFundForPriority() public onlyAfterFund onlyOwner {
        if (priorityTotal<=0) revert Errors.PriorityEmptyError(priorityTotal);
        uint num = PriorityAddress.length;
        uint _cursor = 0;
        for (uint i=0; i<num; i++){
            (bool success, ) = PriorityAddress[_cursor].call{value: Total*PriorityMapping[PriorityAddress[_cursor]]/priorityTotal}("");
            require(success, "send failed");
            _cursor += 1;
        }
    }

    function Deposit(address account) public payable onlyAfterFirstBuy {
        if (account == address(0)) revert Errors.DepositAccountError(account);
        if (msg.value < MIN_VALUE || msg.value > MAX_VALUE) revert Errors.DepositAmountError(MIN_VALUE,MAX_VALUE,msg.value);
        Total += msg.value;
        OwnFundAmount[account] += msg.value;
    }

    function BuyToken(uint amount, uint expect_num) public nonReentrant {
        equiToken.getToken(amount, expect_num);
        OwnFundAmount[msg.sender] -= amount;
    }

    function BuyNFT(uint amount, uint expect_num) public nonReentrant {
        uint restAmount = equiNFT.getNFT(amount, expect_num);
        OwnFundAmount[msg.sender] = restAmount;
    }

    function BuyDeposit(uint amount, uint expect_num) public nonReentrant {
        equiDeposit.getToken(amount, expect_num);
        OwnFundAmount[msg.sender] -= amount;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
    
}