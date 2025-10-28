// SPDX-License-Identifier: MIT
//修改sodility版本，确保版本一致性
pragma solidity ^0.8.0;

/**
 * @title Proxy
 * @notice EIP-1967 compliant upgradeable proxy contract
 * @dev Proxy使用EIP-1967标准存储槽以避免存储槽冲突
 *      - Implementation slot: keccak256("eip1967.proxy.implementation") - 1
 *      - Admin slot: keccak256("eip1967.proxy.admin") - 1
 */
contract Proxy {
    // EIP-1967 存储槽
    // bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    bytes32 private constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    bytes32 private constant ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    // Events
    event Upgraded(address indexed newImplementation);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    constructor(address _implementation, address _admin) {
        require(
            _implementation != address(0),
            "Implementation cannot be zero address"
        );
        require(_admin != address(0), "Admin cannot be zero address");

        _setImplementation(_implementation);
        _setAdmin(_admin);
    }

    /**
     * @notice 获取实现地址
     */
    function implementation() external view returns (address impl) {
        assembly {
            impl := sload(IMPLEMENTATION_SLOT)
        }
    }

    /**
     * @notice 获取管理员地址
     */
    function admin() external view returns (address adm) {
        assembly {
            adm := sload(ADMIN_SLOT)
        }
    }

    /**
     * @notice 升级/部署新的实现地址
     */
    function upgradeTo(address newImplementation) external {
        require(msg.sender == _getAdmin(), "Only admin can upgrade");
        require(
            newImplementation != address(0),
            "New implementation cannot be zero address"
        );

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @notice 修改管理员地址
     */
    function changeAdmin(address newAdmin) external {
        require(msg.sender == _getAdmin(), "Only admin can change admin");
        require(newAdmin != address(0), "New admin cannot be zero address");

        address oldAdmin = _getAdmin();
        _setAdmin(newAdmin);
        emit AdminChanged(oldAdmin, newAdmin);
    }

    function _setImplementation(address _implementation) private {
        assembly {
            sstore(IMPLEMENTATION_SLOT, _implementation)
        }
    }

    function _setAdmin(address _admin) private {
        assembly {
            sstore(ADMIN_SLOT, _admin)
        }
    }

    function _getImplementation() private view returns (address impl) {
        assembly {
            impl := sload(IMPLEMENTATION_SLOT)
        }
    }

    function _getAdmin() private view returns (address adm) {
        assembly {
            adm := sload(ADMIN_SLOT)
        }
    }

    /**
     * @notice 当用户调用代理合约中不存在的函数时，自动将这个调用转发到实现合约去执行。感觉有点像interfacce，哈哈
     */
    fallback() external payable {
        address impl = _getImplementation();

        assembly {
            // Copy msg.data to memory
            calldatacopy(0, 0, calldatasize())

            // Delegate call to implementation
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // Copy return data to memory
            returndatacopy(0, 0, returndatasize())
            //很代理，很皮包。。。：）

            // Return or revert based on result
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @notice Receive function to accept ether
     */
    receive() external payable {}
}
