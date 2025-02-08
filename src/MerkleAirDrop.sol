// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title MerkleAirDrop
 * @author Anurag
 * @dev A contract for distributing ERC20 tokens to a list of claimers using a Merkle proof concept.
 */
contract MerkleAirDrop is EIP712 {
    using SafeERC20 for IERC20;

    //// errors ////
    error MerkleAirDrop__InvalidProof();
    error MerkleAirDrop__AlreadyClaimed();
    error MerkleAirDrop__InvalidSignature();

    //// Event ////
    event Claim(address account, uint256 amount);

    //// storage variable ////
    mapping(address claimer => bool claimed) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirDrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /**
     * @notice Allows an eligible claimer to claim their allocated tokens.
     * @param account The address of the user claiming the tokens.
     * @param amount The amount of tokens being claimed.
     * @param merkleProof  The Merkle proof to verify the claim.
     * @dev Reverts if the address has already claimed or the proof is invalid.
     * The leaf node is created by hashing the claimer's address and the claim amount.
     * Two times hashing is done to avoid hash collisions.
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (s_hasClaimed[account]) {
            revert MerkleAirDrop__AlreadyClaimed();
        }
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirDrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirDrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner, /*ECDSA.RecoverError recoverError*/, /*bytes32 signatureLength*/ ) =
            ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
    //// getter functions ////

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirDropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
