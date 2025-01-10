// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { RankingRecord, Plants, TotalPlants, PlantsLevel, PlantsLevelData, PlayerPlantingRecord, PlayerPlantingRecordData, CurrentPlayerPlants, CurrentPlayerPlantsData } from "../codegen/index.sol";
import { Random } from "../libraries/Random.sol";
import { Check } from "../libraries/Check.sol";

contract PlantsSystem is System {
    function collectSeed() public {
        address sender = _msgSender();
        uint256 plantsAmount = TotalPlants.get(0);
        uint256 plantsId = (Random.getRandomNumber(plantsAmount, sender) % plantsAmount) + 1;

        Check.requireLevelSet(plantsId, 1);
        uint256 growScore;
        uint256 totalScoreConsumed;

        uint256 currentChangeTimes = CurrentPlayerPlants.getChangeTimes(sender);
        uint256 currentLevel = CurrentPlayerPlants.getLevel(sender);

        if(currentLevel > 0){
            (growScore, totalScoreConsumed) = Check.checkChangeScoreSufficiency(currentChangeTimes, sender);
            currentChangeTimes += 1;
        }else{
            (growScore, totalScoreConsumed) = Check.checkScoreSufficiency(plantsId, 1, sender);
        }
  
        uint256 newTotalScoreConsumed = totalScoreConsumed + growScore;

        CurrentPlayerPlants.set(sender, plantsId, 1, block.timestamp, currentChangeTimes);
        PlayerPlantingRecord.setScores(0, sender, newTotalScoreConsumed);
        PlayerPlantingRecord.setScores(plantsId, sender, PlayerPlantingRecord.getScores(plantsId, sender) + growScore);
    }

    function grow() public {
        address owner = _msgSender();
        CurrentPlayerPlantsData memory currentPlayerPlantsData = CurrentPlayerPlants.get(owner);
        uint256 currentPlantsId = currentPlayerPlantsData.plantsId;
        uint256 nextLevel = currentPlayerPlantsData.level + 1;
        require(currentPlantsId != 0, "No Plants");

        Check.requireLevelSet(currentPlantsId, nextLevel);

        PlantsLevelData memory plantsLevelData = PlantsLevel.get(currentPlantsId, nextLevel);
        uint256 growScore = plantsLevelData.score;
        require(block.timestamp >= currentPlayerPlantsData.growTime + plantsLevelData.intervalTime, "The growth time is too short");
        
        Check.checkScoreSufficiency(currentPlantsId, nextLevel, owner);
        
        // total plants record
        PlayerPlantingRecordData memory totalPlantingRecordData = PlayerPlantingRecord.get(0, owner);
        uint256 newTotalScoreConsumed = totalPlantingRecordData.scores + growScore;
        // current plants record
        PlayerPlantingRecordData memory currentPlantingRecordData = PlayerPlantingRecord.get(currentPlantsId, owner);
        
        uint256 plantsLevel = Plants.getPlantLevel(currentPlantsId);
   
        if(nextLevel == plantsLevel){
            PlayerPlantingRecord.set(0, owner, newTotalScoreConsumed, totalPlantingRecordData.plantsAmount+1);
            PlayerPlantingRecord.set(currentPlantsId, owner, currentPlantingRecordData.scores + growScore, currentPlantingRecordData.plantsAmount+1);
            CurrentPlayerPlants.set(owner, 0, 0, 0, 0);
        }else{
            PlayerPlantingRecord.set(0, owner, newTotalScoreConsumed, totalPlantingRecordData.plantsAmount);
            PlayerPlantingRecord.set(currentPlantsId, owner, currentPlantingRecordData.scores + growScore, currentPlantingRecordData.plantsAmount);
            CurrentPlayerPlants.set(owner, currentPlantsId, nextLevel, block.timestamp, currentPlayerPlantsData.changeTimes);
        }

    }
}