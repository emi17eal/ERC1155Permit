// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IERC1155Permit} from "./IERC1155Permit.sol";
import {EIP712, ECDSA} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

error SignatureExpired();
error SignatureError();

contract ERC1155Permit is ERC1155, IERC1155Permit, EIP712 {
    mapping(address => uint256) public nonces;

    bytes32 private immutable PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address operator,bool approved,uint256 nonce,uint256 deadline)");

    constructor() ERC1155("test") EIP712("ERC1155Permit", "1") {}

    function permit(address owner, address operator, bool approved, uint256 deadline, bytes memory sig) external {
        if (block.timestamp > deadline) revert SignatureExpired();

        bytes32 structHash =
            keccak256(abi.encode(PERMIT_TYPEHASH, owner, operator, approved, nonces[owner]++, deadline));

        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, sig);

        if (signer != owner) revert SignatureError();

        _setApprovalForAll(owner, operator, approved);
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }
}
