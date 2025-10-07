// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Proxy {
    address public implementation;
    address public admin;

    constructor(address _implementation, address _admin) {
        implementation = _implementation;
        admin = _admin;
    }

    function upgrade_to(address _new_implementation) external {
        require(msg.sender == admin, "not admin");
        implementation = _new_implementation;
    }

    function update_admin(address _new_admin) external {
        require(msg.sender == admin, "not admin");
        admin = _new_admin;
    }

    fallback() external payable {
        _delegate(implementation);
    }

    receive() external payable {
        _delegate(implementation);
    }

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

