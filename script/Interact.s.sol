// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {MerkleAirDrop} from "../src/MerkleAirDrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract ClaimAirdrop is Script {
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25e18;
    bytes32 PROOF1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [PROOF1, PROOF2];
    bytes private SIGNATURE =
        hex"aba18789a3d419a29f4e05dbf5659eb02b19d94b48e17c00fe709bc11273f4253f6eba8120c1b1a4b4a9c8fa56218ad80ed42ec6d5e166b09ccd65064e4a306d1c";

    error __ClaimAirDrop_InvalidSignatureLength();

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirDrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, PROOF, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert __ClaimAirDrop_InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirDrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
