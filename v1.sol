// LogicV1.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicV1 {
    address public implementation;
    address public admin;

    uint256 public value;

    function setValue(uint256 _value) public {
        value = _value;
    }
}

