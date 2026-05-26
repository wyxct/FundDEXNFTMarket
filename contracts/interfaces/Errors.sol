// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Errors {
    error FundAmountError(uint MIN_FUND, uint MAX_FUND, uint CURRENT_FUND);
    error RefundAmountError(uint RefundAmount);
    error GetFundAmountError(uint Amount);
    error PersonAddrError(address Person);
    error ClaimTokenAmountError(uint restNum, uint claimNum);
    error ClaimNFTAmountError(uint restNum, uint claimNum);
    error NeedTokenNumError(uint TokenNum, uint NeedNum);
    error NeedNFTNumError(uint NFTNum, uint NeedNum);
    error PriorityError(address user, uint priority);
    error PriorityEmptyError(uint totalPriority);
    error DepositAccountError(address account);
    error DepositAmountError(uint MIN_FUND, uint MAX_FUND, uint CURRENT_AMOUNT);
    error SwapAddrError(address tokenA, address tokenB, address swapToken);
    error LiquidityAmountError(uint Amount1, uint Amount2);
    error LiquidityPercentError(uint Amount1, uint Amount2);
    error SwapAmountError(uint amount);
    error ExpectAmountError(uint expectAmount, uint realAmount);
}