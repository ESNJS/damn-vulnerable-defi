// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console2.sol";
import "forge-std/Test.sol";
import { AccountingToken } from "src/05.the-rewarder/AccountingToken.sol";
import { FlashLoanerPool } from "src/05.the-rewarder/FlashLoanerPool.sol";
import { RewardToken } from "src/05.the-rewarder/RewardToken.sol";
import { TheRewarderPool } from "src/05.the-rewarder/TheRewarderPool.sol";
import { DamnValuableToken } from "src/DamnValuableToken.sol";

contract ChallengeTheRewarder is Test {
  FlashLoanerPool public flashLoanPool;
  TheRewarderPool public rewarderPool;
  DamnValuableToken public liquidityToken;
  RewardToken public rewardToken;
  AccountingToken public accountingToken;

  uint256 constant TOKENS_IN_LENDER_POOL = 1_000_000 ether;

  address public deployer = makeAddr("deployer");
  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");
  address public charlie = makeAddr("charlie");
  address public david = makeAddr("david");
  address public player = makeAddr("player");
  address[] public users = [alice, bob, charlie, david];

  function setUp() public {
    /**
     * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
     */
    vm.startPrank(deployer);
    liquidityToken = new DamnValuableToken();
    flashLoanPool = new FlashLoanerPool(address(liquidityToken));

    // Set initial token balance of the pool offering flash loans
    liquidityToken.transfer(address(flashLoanPool), TOKENS_IN_LENDER_POOL);

    rewarderPool = new TheRewarderPool(address(liquidityToken));
    rewardToken = rewarderPool.rewardToken();
    accountingToken = rewarderPool.accountingToken();

    // Check roles in accounting token
    assertEq(accountingToken.owner(), address(rewarderPool));
    uint256 minterRole = accountingToken.MINTER_ROLE();
    uint256 snapshotRole = accountingToken.SNAPSHOT_ROLE();
    uint256 burnerRole = accountingToken.BURNER_ROLE();
    assertEq(
      accountingToken.hasAllRoles(
        address(rewarderPool), minterRole | snapshotRole | burnerRole
      ),
      true
    );

    // Alice, Bob, Charlie and David deposit tokens
    uint256 depositAmount = 100 ether;
    for (uint256 i = 0; i < users.length; i++) {
      liquidityToken.transfer(users[i], depositAmount);
      changePrank(users[i]);
      liquidityToken.approve(address(rewarderPool), depositAmount);
      rewarderPool.deposit(depositAmount);
      assertEq(accountingToken.balanceOf(users[i]), depositAmount);
      changePrank(deployer);
    }
    assertEq(accountingToken.totalSupply(), depositAmount * users.length);
    assertEq(rewardToken.totalSupply(), 0);

    // Advance time 5 days so that depositors can get rewards
    skip(5 days);

    // Each depositor gets reward tokens
    uint256 rewardsInRound = rewarderPool.REWARDS();
    for (uint256 i = 0; i < users.length; i++) {
      changePrank(users[i]);
      rewarderPool.distributeRewards();
      assertEq(rewardToken.balanceOf(users[i]), rewardsInRound / users.length);
    }

    assertEq(rewardToken.totalSupply(), rewardsInRound);

    // Player starts with zero DVT tokens in balance
    assertEq(liquidityToken.balanceOf(player), 0);

    // Two rounds must have occurred so far
    assertEq(rewarderPool.roundNumber(), 2);
  }

  function test_solution() public {
    /**
     * CODE YOUR SOLUTION HERE
     */
    changePrank(player);

    /**
     * SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE
     */
    // Only one round must have taken place
    assertEq(rewarderPool.roundNumber(), 3);

    // Users should get neglegible rewards this round
    for (uint256 i = 0; i < users.length; i++) {
      changePrank(users[i]);
      rewarderPool.distributeRewards();
      uint256 userRewards = rewardToken.balanceOf(users[i]);
      uint256 delta = userRewards - rewarderPool.REWARDS() / users.length;
      assertLt(delta, 10 ** 16);
    }

    // Rewards must have been issued to the player account
    assertGt(rewardToken.totalSupply(), rewarderPool.REWARDS());
    uint256 playerRewards = rewardToken.balanceOf(player);
    assertGt(playerRewards, 0);

    // The amount of rewards earned should be close to total available amount
    uint256 delta = rewarderPool.REWARDS() - playerRewards;
    assertLt(delta, 10 ** 17);

    // Balance of DVT tokens in player and lending pool hasn't changed
    assertEq(liquidityToken.balanceOf(player), 0);
    assertEq(
      liquidityToken.balanceOf(address(flashLoanPool)), TOKENS_IN_LENDER_POOL
    );
  }
}
