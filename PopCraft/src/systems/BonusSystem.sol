// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { UserBenefitsToken, Token, TokenBalance, TokenSold, TokenSoldData } from "../codegen/index.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";

contract BonusSystem is System {
  function getUserBenefitsToken() public {
    address user = _msgSender();

    require(!UserBenefitsToken.get(user), "Already obtained");

    UserBenefitsToken.set(user, true);
    address[] memory priTokenAddr = Token.get(1);
    uint256 priTokenAddrLength = priTokenAddr.length;
    uint256 benefitsAmount = 2 * 10 ** 18;
    for (uint256 i; i < priTokenAddrLength; i++) {
      address tokenAddr = priTokenAddr[i];
      TokenBalance.set(user, tokenAddr, TokenBalance.get(user, tokenAddr) + benefitsAmount);

      TokenSoldData memory tokenSoldData = TokenSold.get(tokenAddr);
      TokenSold.set(tokenAddr, tokenSoldData.soldNow + benefitsAmount, tokenSoldData.soldAll + benefitsAmount);
    }
  }
}
