// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {MerkleAirDrop} from "../src/MerkleAirDrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DeployMerkleAirDrop is Script {
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToTransfer = 4 * 25e18;

    function deployMerkleAirDrop() public returns (MerkleAirDrop, BagelToken) {
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirDrop airdrop = new MerkleAirDrop(s_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirDrop, BagelToken) {
        return deployMerkleAirDrop();
    }
}
