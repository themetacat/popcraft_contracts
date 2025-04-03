// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { TokenSoldData, TokenSold, TokenBalance } from "../codegen/index.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";
import { UniversalRouterParams } from "../core_codegen/index.sol";

contract BuySystem is System {
  receive() external payable {}

  function buyToken(UniversalRouterParams[] calldata universalRouterParams) public payable {
    require(_msgValue() > 0, "msgValue < 0");
    (
      UniversalRouterParams[] memory resultParams,
      uint256 value,
      UniversalRouterParams[] memory priResultParams,
      uint256 valuePri
    ) = Check.dealUniversalRouterParams(universalRouterParams);
    require(resultParams.length == 0, "token > 0");
    // add erc20 token: change here !!!
    // require(_msgValue() >= value + valuePri, "Insufficient");
    Check.checkPriTokenPirce(priResultParams, _msgValue(), _msgSender());

    for (uint256 i; i < priResultParams.length; i++) {
      address token_addr = priResultParams[i].token_info.token_addr;
      uint256 amount = priResultParams[i].token_info.amount;

      TokenSoldData memory tokenSoldData = TokenSold.get(token_addr);
      TokenSold.set(token_addr, tokenSoldData.soldNow + amount, tokenSoldData.soldAll + amount);

      uint256 balance = TokenBalance.get(_msgSender(), token_addr);
      TokenBalance.set(_msgSender(), token_addr, balance + amount);
    }
  }
}
