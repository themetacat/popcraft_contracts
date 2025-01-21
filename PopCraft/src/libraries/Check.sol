// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { RankingRecord, PlantsLevel, PlantsLevelData, PlayerPlantingRecord, Token, PriTokenPrice } from "../codegen/index.sol";
import { UniversalRouterParams } from "../core_codegen/index.sol";

library Check {
  function checkScoreSufficiency(
    uint256 plantsId,
    uint256 level,
    address owner
  ) internal view returns (uint256, uint256) {
    uint256 growScore = PlantsLevel.getScore(plantsId, level);
    uint256 playerTotalScore = RankingRecord.getTotalScore(owner);
    uint256 totalScoreConsumed = PlayerPlantingRecord.getScores(0, owner);
    uint256 availableScore = 0;

    if (totalScoreConsumed < playerTotalScore) {
      availableScore = playerTotalScore - totalScoreConsumed;
    }
    require(availableScore >= growScore, "Insufficient score");
    return (growScore, totalScoreConsumed);
  }

  function checkChangeScoreSufficiency(uint256 changeTimes, address owner) internal view returns (uint256, uint256) {
    if (changeTimes > 3) {
      changeTimes = 3;
    }

    uint256 growScore = 2000 + changeTimes * 1000;
    uint256 playerTotalScore = RankingRecord.getTotalScore(owner);
    uint256 totalScoreConsumed = PlayerPlantingRecord.getScores(0, owner);
    uint256 availableScore = 0;

    if (totalScoreConsumed < playerTotalScore) {
      availableScore = playerTotalScore - totalScoreConsumed;
    }
    require(availableScore >= growScore, "Insufficient score");

    return (growScore, totalScoreConsumed);
  }

  function requireLevelSet(uint256 plantsId, uint256 level) internal view {
    PlantsLevelData memory plantsLevelData = PlantsLevel.get(plantsId, level);
    require(plantsLevelData.intervalTime != 0 || plantsLevelData.score != 0, "Level parameter not set");
  }

  function dealUniversalRouterParams(
    UniversalRouterParams[] memory universalRouterParams
  ) internal view returns (UniversalRouterParams[] memory, uint256, UniversalRouterParams[] memory, uint256) {
    uint256 router_params_length = universalRouterParams.length;
    address[] memory priTokenAddr = Token.get(1);

    UniversalRouterParams[] memory filteredParams = new UniversalRouterParams[](router_params_length);
    UniversalRouterParams[] memory priResultParams = new UniversalRouterParams[](router_params_length);
    uint256 count = 0;
    uint256 priCount = 0;

    for (uint256 i = 0; i < router_params_length; i++) {
      bool isPrivateToken = false;
      for (uint256 j = 0; j < priTokenAddr.length; j++) {
        if (universalRouterParams[i].token_info.token_addr == priTokenAddr[j]) {
          isPrivateToken = true;
          break;
        }
      }
      if (isPrivateToken) {
        priResultParams[priCount] = universalRouterParams[i];
        priCount++;
      } else {
        filteredParams[count] = universalRouterParams[i];
        count++;
      }
    }

    UniversalRouterParams[] memory resultParams = new UniversalRouterParams[](count);
    uint256 value = 0;
    for (uint256 k = 0; k < count; k++) {
      resultParams[k] = filteredParams[k];
      value += filteredParams[k].value;
    }

    UniversalRouterParams[] memory finalPriResultParams = new UniversalRouterParams[](priCount);
    uint256 valuePri = 0;
    for (uint256 p = 0; p < priCount; p++) {
      finalPriResultParams[p] = priResultParams[p];
      valuePri += priResultParams[p].value;
    }

    return (resultParams, value, priResultParams, valuePri);
  }

  function checkPriTokenPirce(UniversalRouterParams[] memory priResultParams, uint256 value) internal view {
    uint256 pararmLength = priResultParams.length;
    uint256 totalPrice;
    for (uint256 i; i < pararmLength; i++) {
      totalPrice += PriTokenPrice.get(priResultParams[i].token_info.token_addr) * priResultParams[i].token_info.amount /1e18;
    }
    require(totalPrice == value, "Insufficient payment amount");
  }

  function checkIsPriToken(address tokenAddr) internal view returns (bool) {
    address[] memory priTokenAddr = Token.get(1);
    uint256 priTokenAddrLength = priTokenAddr.length;
    for (uint256 i; i < priTokenAddrLength; i++) {
      if (priTokenAddr[i] == tokenAddr) {
        return true;
      }
    }
    return false;
  }
}
