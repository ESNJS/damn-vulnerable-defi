// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "src/04.side-entrance/SideEntranceLenderPool.sol";
import "src/player-contracts/04.side-entrance/FlashLoanEtherReceiver.sol";
import "src/DamnValuableToken.sol";

contract ChallengeSideEntrance is Test {
  SideEntranceLenderPool public pool;

  uint256 constant ETHER_IN_POOL = 1000 ether;
  uint256 constant PLAYER_INITIAL_ETH_BALANCE = 1 ether;

  address public deployer = makeAddr("deployer");
  address public player = makeAddr("player");

  function setUp() public {
    /**
     * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
     */
    vm.deal(deployer, ETHER_IN_POOL);
    vm.startPrank(deployer);

    // Deploy pool and fund it
    pool = new SideEntranceLenderPool();
    pool.deposit{ value: ETHER_IN_POOL }();
    assertEq(address(pool).balance, ETHER_IN_POOL);

    // Player starts with limited ETH in balance
    vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
    assertEq(address(player).balance, PLAYER_INITIAL_ETH_BALANCE);
  }

  function test_solution() public {
    /**
     * CODE YOUR SOLUTION HERE
     */
    changePrank(player);
    FlashLoanEtherReceiver receiver = new FlashLoanEtherReceiver();
    receiver.init();

    /**
     * SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE
     */

    // Player took all ETH from the pool
    assertEq(address(pool).balance, 0);
    assertGt(address(player).balance, ETHER_IN_POOL);
  }
}
