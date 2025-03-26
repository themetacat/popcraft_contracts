// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { RankingRecord, PlantsLevel, PlantsLevelData, PlayerPlantingRecord, Token, PriTokenPrice, ComboRewardGames, ComboRewardGamesData, SeasonTime, SeasonTimeData, NFTToTokenDiscount } from "../codegen/index.sol";
import { UniversalRouterParams } from "../core_codegen/index.sol";
import { Utils } from "./Utils.sol";
import { IERC721 } from "../interfaces/IERC721.sol";


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

    return (resultParams, value, finalPriResultParams, valuePri);
  }

  function checkPriTokenPirce(UniversalRouterParams[] memory priResultParams, uint256 value, address player) internal view {
    uint256 pararmLength = priResultParams.length;
    uint256 totalPrice;
    for (uint256 i; i < pararmLength; i++) {
      totalPrice +=
        (PriTokenPrice.get(priResultParams[i].token_info.token_addr) * priResultParams[i].token_info.amount) /
        1e18;
    }
    uint256 NFTBalance = IERC721(0xf6e9932469CBde5dB4b9293330Ff1897Bb43b2AE).balanceOf(player);
    uint256 discount = 0;
    if(NFTBalance > 0){
      if(NFTBalance > NFTToTokenDiscount.get(0)){
        discount = NFTToTokenDiscount.get(NFTToTokenDiscount.get(0));
      }else{
        discount = NFTToTokenDiscount.get(NFTBalance);
      }
    }
    require((totalPrice * (100 - discount)) / 100 == value, "Insufficient payment amount");
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

  function check_pop_access(
    uint256 matrix_index,
    uint256 target_value,
    uint256[] memory matrix_array
  ) public pure returns (bool) {
    uint256 x = matrix_index % 10;
    uint256 y = matrix_index / 10;

    uint256 index;
    if (x > 0) {
      index = matrix_index - 1;
      if (matrix_array[index] == target_value) {
        return true;
      }
    }

    if (x < 9) {
      index = matrix_index + 1;
      if (matrix_array[index] == target_value) {
        return true;
      }
    }

    if (y > 0) {
      index = matrix_index - 10;
      if (matrix_array[index] == target_value) {
        return true;
      }
    }

    if (y < 9) {
      index = matrix_index + 10;
      if (matrix_array[index] == target_value) {
        return true;
      }
    }

    return false;
  }

  function check_game_finished(uint256[] memory matrix_array) public pure returns (bool) {
    unchecked {
      for (uint256 i; i < 99; ) {
        if (matrix_array[i] != 0) {
          return false;
        }
        i++;
      }
    }
    return true;
  }

  function checkComboRewardEligibility(address player) public view returns (bool) {
    uint256 currentDay = Utils.getCurrentDayCommon(5);
    if(currentDay == 0){
      return true;
    }
    ComboRewardGamesData memory comboRewardGamesData = ComboRewardGames.get(player);
    if(comboRewardGamesData.addedTime == currentDay && comboRewardGamesData.games >3){
      return false;
    }
    return true;
  }
}
