// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { TokenSoldData, TokenSold, TokenBalance } from "../codegen/index.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";
import { UniversalRouterParams } from "../core_codegen/index.sol";
import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import { IRouterSystem } from "../core_codegen/world/IRouterSystem.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IWorld } from "../core_codegen/world/IWorld.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

contract BuySystem is System {
  string constant NAMESPACE = "popCraft";
  bytes14 constant BYTESNAMESPACE = bytes14(bytes(NAMESPACE));

  receive() external payable {}

  function buyToken(UniversalRouterParams[] calldata universalRouterParams) public payable {
    require(_msgValue() > 0, "msgValue < 0");
    (
      UniversalRouterParams[] memory resultParams,
      uint256 value,
      UniversalRouterParams[] memory priResultParams,
      uint256 valuePri
    ) = Check.dealUniversalRouterParams(universalRouterParams);
    // require(resultParams.length == 0, "token > 0");
    // add erc20 token: change here !!!
    // require(_msgValue() >= value + valuePri, "Insufficient");
    Check.checkPriTokenPirce(priResultParams, _msgValue() - value, _msgSender());
    if (resultParams.length > 0) {
      uint256 balance_last = address(this).balance;
      IWorld(_world()).transferBalanceToAddress(
        WorldResourceIdLib.encodeNamespace(BYTESNAMESPACE),
        address(this),
        value
      );
      uint256 balance_after = address(this).balance;
      require(balance_after - balance_last == value, "Incorrect balance");

      ResourceId systemId = WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: "", name: "RouterSystem" });

      IWorld(address(_world())).call{ value: value }(
        systemId,
        abi.encodeCall(
          IRouterSystem.universalRouterExecute,
          (resultParams, WorldResourceIdLib.encodeNamespace(BYTESNAMESPACE))
        )
      );
    }

    for (uint256 i; i < universalRouterParams.length; i++) {
      address token_addr = universalRouterParams[i].token_info.token_addr;
      uint256 amount = universalRouterParams[i].token_info.amount;

      TokenSoldData memory tokenSoldData = TokenSold.get(token_addr);
      TokenSold.set(token_addr, tokenSoldData.soldNow + amount, tokenSoldData.soldAll + amount);

      uint256 balance = TokenBalance.get(_msgSender(), token_addr);
      TokenBalance.set(_msgSender(), token_addr, balance + amount);
    }
  }
}
