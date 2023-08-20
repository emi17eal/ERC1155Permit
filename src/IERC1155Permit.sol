// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC1155Permit {
    function permit(address owner, address operator, bool approved, uint256 deadline, bytes memory sig) external;
    function nonces (address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}