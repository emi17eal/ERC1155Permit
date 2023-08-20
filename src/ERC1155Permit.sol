// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC1155Permit} from "./IERC1155Permit.sol";

contract ERC1155Permit is IERC1155Permit {
    mapping(address => uint256) public nonces;

    bytes32 private immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address operator,bool approved,uint256 nonce,uint256 deadline)");

    function permit(address owner, address operator, bool approved, uint256 deadline, bytes memory sig) external {

    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        
    }
}
