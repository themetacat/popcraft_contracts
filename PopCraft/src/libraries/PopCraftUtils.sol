// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Token } from "../codegen/index.sol";

library PopCraftUtils {

  function shuffle(address sender) public view returns (uint256[] memory) {
    uint256[] memory matrix = new uint256[](100);
    for (uint256 i = 0; i < 100; ) {
      uint256 random_num = (uint256(keccak256(abi.encodePacked(sender, block.timestamp, block.number, i))) % 5) + 1;
      matrix[i] = random_num;
      unchecked {
        i++;
      }
    }
    return matrix;
  }

  function randomTCMToken() public view returns (address[] memory) {
    address[] memory address_arr = new address[](5);
    address[] memory tempValues = Token.get(0);
    uint256 n = tempValues.length;

    // Fisher-Yates shuffle
    for (uint256 i = 0; i < 5; i++) {
      uint256 randIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, i))) % n;
      address_arr[i] = tempValues[randIndex];
      tempValues[randIndex] = tempValues[n - 1];
      n--;
    }
    address KOALA = 0x0000000000000000000000000000000000000012;
    for (uint256 i = 0; i < 5; i++) {
      if (address_arr[i] == KOALA) {
        break;
      } else {
        if (i == 4) {
          address_arr[i] = KOALA;
        }
      }
    }
    return address_arr;
  }

}
