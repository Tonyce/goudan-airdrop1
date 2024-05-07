// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GoudanAirdrop} from "../src/GoudanAirdrop.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract GoudanAirdropTest is Test {
    GoudanAirdrop public goudanAirdrop;

    bytes32[] public merkleProof;

    function setUp() public {
        address token = address(0x0fc958281DBa627F4C63f952C04b574D77f2b049);

        bytes32 merkleRoot = bytes32(
            0x3b3039b9834d9946e7c40d46c9f9119e3a3209aa5a82a2ce4efd6ab70fba8993
        );
        goudanAirdrop = new GoudanAirdrop(token, merkleRoot);
    }

    function test_claim() public {
        // string[5] memory proofes = [
        //     "0x0f396a0d87acae65aee0332576a6dbb0f467556290372d91b4b6050d5531a0b6",
        //     "0xdfddf7a9ce39b3366f4361178152051f37d9e7682c7b3fd109eacbc73ab1ed4f",
        //     "0x20e9cf6e96fe5d0e5d6e508ef684ad8780282cb9688f5f04357149c4491f547b",
        //     "0xd56b25c5bdf36bc11e535dfdae7d5dffab4e8c12e743361a8ba2f360fbc8cbdd",
        //     "0x94cd412e599bbf0650bcb6255ff8ce9314d9a0a128c86ccde0153b80d4452b6d"
        // ];

        address claimAddr = address(0x8c5cCDD71D3b66cae5D73B22280dA568c0b50b8d);
        // address claimAddr = address(0x6E5372290713088176e78b4f9ae6935760Aeca97);
        uint leafIndex = 1;

        // uint256 n = proofes.length;

        // bytes32[] memory merkleProof = [
        merkleProof.push(
            bytes32(
                0x0f396a0d87acae65aee0332576a6dbb0f467556290372d91b4b6050d5531a0b6
            )
        );
        merkleProof.push(
            bytes32(
                0xdfddf7a9ce39b3366f4361178152051f37d9e7682c7b3fd109eacbc73ab1ed4f
            )
        );
        merkleProof.push(
            bytes32(
                0x20e9cf6e96fe5d0e5d6e508ef684ad8780282cb9688f5f04357149c4491f547b
            )
        );
        merkleProof.push(
            bytes32(
                0xd56b25c5bdf36bc11e535dfdae7d5dffab4e8c12e743361a8ba2f360fbc8cbdd
            )
        );
        merkleProof.push(
            bytes32(
                0x94cd412e599bbf0650bcb6255ff8ce9314d9a0a128c86ccde0153b80d4452b6d
            )
        );

        // for (uint256 i = 0; i < n; i++) {
        //     merkleProof.push(bytes32(bytes(proofes[i])));
        // }

        uint256 amount = 3990000;
        console.logString("claim");
        goudanAirdrop.claim(leafIndex, claimAddr, amount, merkleProof);
        console.logString("claim succeeds");
    }
}
