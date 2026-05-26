// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEquiRaise {

    event Contribute(address indexed from, uint indexed amount);
    event Raise(address from, uint amount);

    function contribute() external payable;
    function getTotalRaise() external view returns(uint);
    function claimToken(uint amount, uint needMinTokens) external;
    function claimNFT(uint amount, uint needMinNFT) external;


}