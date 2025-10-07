// LogicV2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicV2 {
    address public implementation;
    address public admin;

    uint256 public value;

    function setValue(uint256 _value) public {
        value = _value * 2; // 不同逻辑：存储输入的 2 倍
    }
}

