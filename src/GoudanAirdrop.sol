// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "forge-std/console.sol";

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GoudanAirdrop is Ownable {
    using SafeERC20 for IERC20;

    /**
     *  @dev The token to be distributed
     */
    address public immutable TOKEN;

    /**
     *  @dev The merkle root of the distribution
     */
    bytes32 public immutable MERKLE_ROOT;

    /**
     *  @dev This is a packed array of booleans
     */
    mapping(uint256 => uint256) private claimedBitMap;

    /**
     *  @dev This event is triggered whenever a call to #claim succeeds
     */
    event Claimed(
        uint256 indexed index,
        address indexed account,
        uint256 indexed amount
    );

    /**
     *  @dev The airdrop has already been claimed
     */
    error AlreadyClaimed();

    /**
     *  @dev The merkle proof is invalid
     */
    error InvalidProof();

    /**
     *  @dev The end time is in the past
     */
    error EndTimeInPast();

    /**
     *  @dev The claim window has finished
     */
    error ClaimWindowFinished();

    /**
     *  @dev Cannot withdraw during the claim window
     */
    error NoWithdrawDuringClaim();

    constructor(address token_, bytes32 merkleRoot_) Ownable(msg.sender) {
        TOKEN = token_;
        MERKLE_ROOT = merkleRoot_;
    }

    /**
     *  @dev Returns true if the index has been marked claimed
     *  @param index The index of the claimer in the merkle tree
     */
    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    /**
     *  @dev Marks the index as claimed
     *  @param index The index of the claimer in the merkle tree
     */
    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] =
            claimedBitMap[claimedWordIndex] |
            (1 << claimedBitIndex);
    }

    /**
     *  @dev Claim the given amount of the token to the given address
     *  @param index The index of the claimer rank
     *  @param account The account to receive the tokens
     *  @param amount The amount of tokens to claim
     *  @param merkleProof The merkle proof
     */
    function claim(
        uint index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external virtual {
        if (isClaimed(index)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, MERKLE_ROOT, node))
            revert InvalidProof();

        // Mark it claimed and send the token.
        _setClaimed(index);
        IERC20(TOKEN).safeTransfer(account, amount);

        emit Claimed(index, account, amount);
    }

    /**
     *  @dev Withdraw the remaining tokens after the claim window has finished
     */
    function withdraw() external onlyOwner {
        IERC20(TOKEN).safeTransfer(
            msg.sender,
            IERC20(TOKEN).balanceOf(address(this))
        );
    }
}
