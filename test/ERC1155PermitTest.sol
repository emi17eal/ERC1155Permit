// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {ERC1155Permit, SignatureExpired, SignerNotOwner} from "../src/ERC1155Permit.sol";
import {SigUtils} from "./SigUtils.sol";

contract ERC1155PermitTest is Test {
    ERC1155Permit public erc1155Permit;
    SigUtils public sigUtils;

    uint256 deployerPrivateKey = 1;
    uint256 ownerPrivateKey = 2;
    uint256 operatorPrivateKey = 3;

    address deployer = vm.addr(deployerPrivateKey);
    address owner = vm.addr(ownerPrivateKey);
    address operator = vm.addr(operatorPrivateKey);

    function setUp() public {
        erc1155Permit = new ERC1155Permit();
        sigUtils = new SigUtils(erc1155Permit.DOMAIN_SEPARATOR());
    }

    function test_Permit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            operator: operator,
            approved: true,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        bytes memory sig = abi.encodePacked(r, s, v);

        erc1155Permit.permit(
            permit.owner,
            permit.operator,
            permit.approved,
            permit.deadline,
            sig
        );

        assertEq(erc1155Permit.isApprovedForAll(owner, operator), true);
        assertEq(erc1155Permit.nonces(owner), 1);
    }

    function test_PermitRevertsWhenDeadlineExpired() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            operator: operator,
            approved: true,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        bytes memory sig = abi.encodePacked(r, s, v);

        vm.warp(block.timestamp + 2 days); 

        vm.expectRevert(SignatureExpired.selector);

        erc1155Permit.permit(
            permit.owner,
            permit.operator,
            permit.approved,
            permit.deadline,
            sig
        );

    }

    function test_PermitRevertsWhenSignerNotOwner() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            operator: operator,
            approved: true,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        uint256 otherSignerPrivateKey = 5;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(otherSignerPrivateKey, digest);

        bytes memory sig = abi.encodePacked(r, s, v);

        vm.expectRevert(SignerNotOwner.selector);

        erc1155Permit.permit(
            permit.owner,
            permit.operator,
            permit.approved,
            permit.deadline,
            sig
        );

    }
}
