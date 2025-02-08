// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirDrop} from "../src/MerkleAirDrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirDrop} from "../script/DeployMerkleAirDrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirDrop public airdrop;
    BagelToken public token;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 PROOF1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 PROOF2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [PROOF1, PROOF2];
    address gasPayer;
    address user;
    uint256 userPrivKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirDrop deployer = new DeployMerkleAirDrop();
            (airdrop, token) = deployer.deployMerkleAirDrop();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirDrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }

        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        // console.log("User Address: ", user);
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        vm.startPrank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopPrank();

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending Balance:", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
