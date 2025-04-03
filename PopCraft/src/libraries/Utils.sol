// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { WeeklyRecord, CurrentSeasonDimension, SeasonTime, SeasonTimeData, RankingRecord, StarToScore, WeeklyRecordData, TCMPopStar, ScoreToPointsRewards, GameRecord, RankingRecordData, ScoreToPoints, DailyGames } from "../codegen/index.sol";
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

  function updateRankRecord(address owner, uint256 eliminateAmount, bool game_success) internal {
    uint256 score;

    if (eliminateAmount > 5) {
      score = StarToScore.get(5) + StarToScore.get(0) * (eliminateAmount - 5);
    } else {
      score = StarToScore.get(eliminateAmount);
    }
    RankingRecordData memory rankingRecordData = RankingRecord.get(owner);
    uint256 shortestTime = rankingRecordData.shortestTime;
    uint256 lastestScores = rankingRecordData.latestScores + score;
    uint256 totalScore = rankingRecordData.totalScore + score;
    uint256 highestScore = rankingRecordData.highestScore;

    (uint256 csd, uint256 currentSeason) = getCurrentSeason();
    WeeklyRecordData memory weeklyRecordData = WeeklyRecord.get(owner, currentSeason, csd);

    uint256 seasonShortestTime = weeklyRecordData.shortestTime;
    uint256 seasonLastestScores = weeklyRecordData.latestScores + score;
    uint256 seasonTotalScore = weeklyRecordData.totalScore + score;
    uint256 seasonHighestScore = weeklyRecordData.highestScore;

    if (lastestScores >= 250 && !ScoreToPointsRewards.get(owner)) {
      uint256 pointsRewards = ScoreToPoints.get(250);
      GameRecord.setTotalPoints(owner, GameRecord.getTotalPoints(owner) + pointsRewards);
      weeklyRecordData.totalPoints += pointsRewards;
      ScoreToPointsRewards.set(owner, true);
    }

    if (game_success) {
      uint256 successScore = StarToScore.get(101);
      totalScore += successScore;
      lastestScores += successScore;
      seasonTotalScore += successScore;
      seasonLastestScores += successScore;

      uint256 startTime = TCMPopStar.getStartTime(owner);
      uint256 successTime = block.timestamp - startTime;

      if (successTime < shortestTime || shortestTime == 0) {
        shortestTime = successTime;
      }

      if (successTime < seasonShortestTime || seasonShortestTime == 0) {
        seasonShortestTime = successTime;
      }
    }

    RankingRecord.set(
      owner,
      totalScore,
      (lastestScores > highestScore) ? lastestScores : highestScore,
      lastestScores,
      shortestTime
    );

    if (csd > 0 && currentSeason > 0) {
      WeeklyRecord.set(
        owner,
        currentSeason,
        csd,
        seasonTotalScore,
        (seasonLastestScores > seasonHighestScore) ? seasonLastestScores : seasonHighestScore,
        seasonLastestScores,
        seasonShortestTime,
        weeklyRecordData.times,
        weeklyRecordData.successTimes,
        weeklyRecordData.totalPoints
      );
    }
    Invite.addInviteScores(totalScore-(rankingRecordData.totalScore), owner, csd, currentSeason);
  }

  function getCurrentDayFromDailyGames() public view returns (uint256) {
    SeasonTimeData memory seasonTimeData = SeasonTime.get(2);
    if (block.timestamp < seasonTimeData.startTime || seasonTimeData.duration == 0) {
      return 0;
    }
    uint256 currentDay = (block.timestamp - seasonTimeData.startTime) / seasonTimeData.duration + 1;
    return currentDay;
  }

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
