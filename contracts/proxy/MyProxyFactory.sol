// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";

contract MyProxyFactory {

    using Clones for address;
    
    mapping(string => address[]) public proxiesOf;

    event proxyDeployed(
        string indexed businessType,
        address indexed proxy,
        address indexed implementation,
        bytes32 salt
    );

    function deploy(string calldata businessType, 
    address implementation, bytes32 salt, bytes calldata initData) external returns (address proxy) {
        proxy = implementation.cloneDeterministic(salt);
        if (initData.length > 0) {
            (bool success,) = proxy.call(initData);
            require(success, "ProxyFactory: init failed");
        }

        proxiesOf[businessType].push(proxy);
        emit proxyDeployed(businessType, proxy, implementation, salt);
    }

    function predict(address implementation, bytes32 salt) external view returns (address) {
        return implementation.predictDeterministicAddress(salt, address(this));
    }

    function count(string calldata businessType) external view returns(uint256) {
        return proxiesOf[businessType].length;
    }

    function list(string calldata businessType) external view returns(address[] memory){
        return proxiesOf[businessType];
    }

}