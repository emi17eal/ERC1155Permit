// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC1155Permit} from "../src/ERC1155Permit.sol";

contract ERC1155PermitTest is Test {
    ERC1155Permit public erc1155Permit;

    function setUp() public {
        erc1155Permit = new ERC1155Permit();
    }

    function testPermit() public {
        erc1155Permit.permit();
    }
}
