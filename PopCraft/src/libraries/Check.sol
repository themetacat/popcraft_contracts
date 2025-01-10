// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { RankingRecord, PlantsLevel, PlantsLevelData, PlayerPlantingRecord } from "../codegen/index.sol";

library Check {
  function checkScoreSufficiency(uint256 plantsId, uint256 level, address owner) view internal returns(uint256, uint256) {
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

  function checkChangeScoreSufficiency(uint256 changeTimes, address owner) view internal returns(uint256, uint256)  {
    if(changeTimes > 3){
      changeTimes = 3;
    }
    // !!!!!! change score
    uint256 growScore = 20 + changeTimes * 10;
    uint256 playerTotalScore = RankingRecord.getTotalScore(owner);
    uint256 totalScoreConsumed = PlayerPlantingRecord.getScores(0, owner);
    uint256 availableScore = 0;

    if (totalScoreConsumed < playerTotalScore) {
      availableScore = playerTotalScore - totalScoreConsumed;
    }
    require(availableScore >= growScore, "Insufficient score");

    return (growScore, totalScoreConsumed);
  }

  function requireLevelSet(uint256 plantsId, uint256 level) view internal {
    PlantsLevelData memory plantsLevelData = PlantsLevel.get(plantsId, level);
    require(plantsLevelData.intervalTime != 0 || plantsLevelData.score != 0, "Level parameter not set");
  }
}
