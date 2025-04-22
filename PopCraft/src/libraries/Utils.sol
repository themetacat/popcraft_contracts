// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { CurrentSeasonDimension, SeasonTime, SeasonTimeData, RankingRecord } from "../codegen/index.sol";
import { Invite } from "./Invite.sol";

library Utils {
  function getCurrentSeason() public view returns (uint256, uint256) {
    uint256 csd = CurrentSeasonDimension.get(0);
    SeasonTimeData memory seasonTimeData = SeasonTime.get(csd);
    if (block.timestamp < seasonTimeData.startTime || seasonTimeData.duration == 0) {
      return (0, 0);
    }
    uint256 currentSeason = ((block.timestamp - seasonTimeData.startTime) / seasonTimeData.duration) + 1;
    return (csd, currentSeason);
  }

  function getCurrentDayFromDailyGames() public view returns (uint256) {
    SeasonTimeData memory seasonTimeData = SeasonTime.get(2);
    if (block.timestamp < seasonTimeData.startTime || seasonTimeData.duration == 0) {
      return 0;
    }
    uint256 currentDay = (block.timestamp - seasonTimeData.startTime) / seasonTimeData.duration + 1;
    return currentDay;
  }

  function getCurrentSteakDayData() public view returns (uint256, uint256) {
    SeasonTimeData memory seasonTimeData = SeasonTime.get(3);
    if (block.timestamp < seasonTimeData.startTime || seasonTimeData.duration == 0) {
      return (0, 0);
    }
    uint256 day = SeasonTime.get(4).duration;
    if(day == 0){
      day = 86400;
    }
    uint256 timeElapsed = block.timestamp - seasonTimeData.startTime;
    uint256 totalCycleTimes = timeElapsed / seasonTimeData.duration + 1;
    uint256 timesInCurrentCycle = (timeElapsed % seasonTimeData.duration) / day + 1;

    return (totalCycleTimes, timesInCurrentCycle);
  }

  function dfs(
    uint256 matrix_index,
    uint256 target_value,
    uint256[] memory matrix_array,
    uint256 eliminate_amount
  ) public returns (uint256[] memory, uint256) {
    uint256 x = matrix_index % 10;
    uint256 y = matrix_index / 10;

    uint256 index;
    if (x > 0) {
      index = matrix_index - 1;
      if (matrix_array[index] == target_value) {
        matrix_array[index] = 0;
        eliminate_amount += 1;
        (matrix_array, eliminate_amount) = dfs(index, target_value, matrix_array, eliminate_amount);
      }
    }

    if (x < 9) {
      index = matrix_index + 1;
      if (matrix_array[index] == target_value) {
        matrix_array[index] = 0;
        eliminate_amount += 1;
        (matrix_array, eliminate_amount) = dfs(index, target_value, matrix_array, eliminate_amount);
      }
    }

    if (y > 0) {
      index = matrix_index - 10;
      if (matrix_array[index] == target_value) {
        matrix_array[index] = 0;
        eliminate_amount += 1;
        (matrix_array, eliminate_amount) = dfs(index, target_value, matrix_array, eliminate_amount);
      }
    }

    if (y < 9) {
      index = matrix_index + 10;
      if (matrix_array[index] == target_value) {
        matrix_array[index] = 0;
        eliminate_amount += 1;
        (matrix_array, eliminate_amount) = dfs(index, target_value, matrix_array, eliminate_amount);
      }
    }

    return (matrix_array, eliminate_amount);
  }

  function getCurrentDayCommon(uint256 latitude) public view returns (uint256) {
    SeasonTimeData memory seasonTimeData = SeasonTime.get(latitude);
    if (block.timestamp < seasonTimeData.startTime || seasonTimeData.duration == 0) {
      return 0;
    }
    uint256 currentDay = (block.timestamp - seasonTimeData.startTime) / seasonTimeData.duration + 1;
    return currentDay;
  }
}
