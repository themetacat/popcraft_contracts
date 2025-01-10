// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

library Random {
  /*
   * not real random
   */
  function getRandomNumber(uint256 i, address sender) internal view returns (uint256) {
    return uint256(keccak256(abi.encode(block.timestamp, block.number, i, sender)));
  }

  
}
