// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BusinessImpl is Initializable {
    uint256 public value;

    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 _v) external initializer {
        value = _v;
    }

    function inc() external {
        value += 1;
    }
}