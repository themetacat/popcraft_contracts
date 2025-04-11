// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { ExchangeGpTokenData } from "../libraries/Struct.sol";
import { GPConsumeValue, GameRecord, TotalPlants, PlayerPlantingRecord, PlantsToGP, TokenBalance, TokenSoldData, TokenSold } from "../codegen/index.sol";
import { Check } from "../libraries/Check.sol";

contract ExchangeSystem is System {
  function gpExchangeToken(ExchangeGpTokenData[] memory exchangeGpTokenData) public {
    address player = _msgSender();
    uint256 totalPoints = GameRecord.getTotalPoints(player);
    totalPoints += getPlantsGp(player);
    require(totalPoints > 0, "Insufficient GP");

    uint256 needGp = 0;
    for (uint256 index = 0; index < exchangeGpTokenData.length; index++) {
      address token = exchangeGpTokenData[index].token;
      require(Check.checkIsPriToken(token), "Invalid token");
      needGp += 300 * (exchangeGpTokenData[index].amount);
    }

    uint256 consumeValue = GPConsumeValue.getValue(player);
    require(totalPoints - consumeValue >= needGp, "Insufficient GP");
    
    for (uint256 index = 0; index < exchangeGpTokenData.length; index++) {
      address token = exchangeGpTokenData[index].token;
      uint256 exchangeAmount = exchangeGpTokenData[index].amount * 1e18;

      TokenBalance.set(player, token, TokenBalance.get(player, token) + exchangeAmount);
      TokenSoldData memory tokenSoldData = TokenSold.get(token);
      TokenSold.set(token, tokenSoldData.soldNow + exchangeAmount, tokenSoldData.soldAll + exchangeAmount);
    }
    GPConsumeValue.setValue(player, consumeValue + needGp);
  }

  function getPlantsGp(address player) public view returns (uint256) {
    uint256 totalPlantsAmount = TotalPlants.getTotalAmount(0);
    uint256 totalPlantsGp = 0;
    for (uint256 index = 1; index <= totalPlantsAmount; index++) {
      uint256 playerPlantsAmount = PlayerPlantingRecord.getPlantsAmount(index, player);
      totalPlantsGp += PlantsToGP.getPoints(index) * playerPlantsAmount;
    }
    return totalPlantsGp;
  }
}
