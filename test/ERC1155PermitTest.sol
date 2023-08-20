// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {ERC1155Permit, SignatureExpired, SignatureError} from "../src/ERC1155Permit.sol";
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

    function _signPermit(
        uint256 privateKey,
        address _owner,
        address _operator,
        bool _approved,
        uint256 _nonce,
        uint256 _deadline
    ) private view returns (bytes memory sig) {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: _owner,
            operator: _operator,
            approved: _approved,
            nonce: _nonce,
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        sig = abi.encodePacked(r, s, v);
    }

    function test_Permit() public {
        bytes memory sig = _signPermit(ownerPrivateKey, owner, operator, true, 0, 1 days);

        erc1155Permit.permit(owner, operator, true, 1 days, sig);

        assertEq(erc1155Permit.isApprovedForAll(owner, operator), true);
        assertEq(erc1155Permit.nonces(owner), 1);
    }

    function test_PermitRevertsWhenDeadlineExpired() public {
        bytes memory sig = _signPermit(ownerPrivateKey, owner, operator, true, 0, 1 days);

        vm.warp(block.timestamp + 2 days);

        vm.expectRevert(SignatureExpired.selector);

        erc1155Permit.permit(owner, operator, true, 1 days, sig);
    }

    function test_PermitRevertsWhenSignatureError() public {
        uint256 otherPrivateKey = 5;

        bytes memory sig = _signPermit(otherPrivateKey, owner, operator, true, 0, 1 days);

        vm.expectRevert(SignatureError.selector);

        erc1155Permit.permit(owner, operator, true, 1 days, sig);
    }
}
