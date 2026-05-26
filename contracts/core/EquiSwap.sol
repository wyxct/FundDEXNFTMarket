// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/Errors.sol";

contract EquiSwap is UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable{

    uint private FEE_PERCENT = 300;
    uint private BASE_PERCENT = 10000;
    IERC20 private tokenA;
    IERC20 private tokenB;
    uint private k;
    mapping(address => uint) private LiquidityPercent;

    event AddLiquidity(uint amount1, uint amount2);
    event RemoveLiquidity(uint amount1, uint amount2);
    event Swap(uint AmountIn,uint AmountOut,address swapAddrIn, address swapAddrOut);

    constructor(){
        _disableInitializers();
    }

    function initialize(address token1, address token2) external initializer{
        __UUPSUpgradeable_init();
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        tokenA = IERC20(token1);
        tokenB = IERC20(token2);
    }

    function addLiquidity(uint amount1, uint amount2) public {
        if (amount1 <=0 || amount2 <=0) revert Errors.LiquidityAmountError(amount1, amount2);
        tokenA.transferFrom(msg.sender, address(this), amount1);
        tokenB.transferFrom(msg.sender, address(this), amount2);
        k = tokenA.balanceOf(address(this)) * tokenB.balanceOf(address(this));
        LiquidityPercent[msg.sender] = amount1/tokenA.balanceOf(address(this))*BASE_PERCENT;
        emit AddLiquidity(amount1, amount2);
    }

    function removeLiquidity(uint amount1, uint amount2) public {
        if (amount1 <=0 || amount2 <=0) revert Errors.LiquidityAmountError(amount1, amount2);
        tokenA.transfer(msg.sender, amount1);
        tokenB.transfer(msg.sender, amount2);
        k = tokenA.balanceOf(address(this)) * tokenB.balanceOf(address(this));
        emit RemoveLiquidity(amount1,amount2);
    }

    function removeLiquidityForPercent(uint percent) public {
        if (percent <=0 || percent > 10000 || LiquidityPercent[msg.sender] < percent) revert Errors.LiquidityPercentError(percent, LiquidityPercent[msg.sender]);
        tokenA.transfer(msg.sender, percent/BASE_PERCENT*tokenA.balanceOf(address(this)));
        tokenB.transfer(msg.sender, percent/BASE_PERCENT*tokenB.balanceOf(address(this)));
        k = tokenA.balanceOf(address(this)) * tokenB.balanceOf(address(this));
        LiquidityPercent[msg.sender] -= percent;
        emit RemoveLiquidity(percent/BASE_PERCENT*tokenA.balanceOf(address(this)),percent/BASE_PERCENT*tokenB.balanceOf(address(this)));
        k = tokenA.balanceOf(address(this)) * tokenB.balanceOf(address(this));
    }

    function swap(address swapToken, uint amount, uint expectAmount) public nonReentrant{
        if (swapToken != address(tokenA) && swapToken != address(tokenB)) revert Errors.SwapAddrError(address(tokenA), address(tokenB), swapToken);
        if (amount <=0) revert Errors.SwapAmountError(amount);
        address swapTokenAddrA = swapToken == address(tokenA) ? address(tokenA) : address(tokenB);
        address swapTokenAddrB = swapToken == address(tokenA) ? address(tokenB) : address(tokenA);
        uint reserveAmountIn = swapToken == address(tokenA) ? tokenA.balanceOf(address(this)) : tokenB.balanceOf(address(this));
        uint reserveAmountOut = swapToken == address(tokenA) ? tokenB.balanceOf(address(this)) : tokenA.balanceOf(address(this));
        uint realAmountIn = amount * (BASE_PERCENT - FEE_PERCENT)/BASE_PERCENT;
        uint realAmountOut = realAmountIn*reserveAmountOut/(realAmountIn+reserveAmountIn);
        if (realAmountOut<expectAmount) revert Errors.ExpectAmountError(expectAmount, realAmountOut);
        IERC20(swapTokenAddrA).transferFrom(msg.sender,address(this),amount);
        IERC20(swapTokenAddrB).transferFrom(address(this),msg.sender,amount);
        emit Swap(amount, realAmountOut, swapTokenAddrA, swapTokenAddrB);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}