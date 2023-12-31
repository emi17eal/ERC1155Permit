// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    bytes32 private immutable PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address operator,bool approved,uint256 nonce,uint256 deadline)");

    struct Permit {
        address owner;
        address operator;
        bool approved;
        uint256 nonce;
        uint256 deadline;
    }

    // computes the hash of a permit
    function getStructHash(Permit memory _permit) internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                PERMIT_TYPEHASH, _permit.owner, _permit.operator, _permit.approved, _permit.nonce, _permit.deadline
            )
        );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(Permit memory _permit) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, getStructHash(_permit)));
    }
}
