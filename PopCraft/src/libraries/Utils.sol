// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { WeeklyRecord, CurrentSeasonDimension, SeasonTime, SeasonTimeData, RankingRecord, StarToScore, WeeklyRecordData, TCMPopStar, ScoreToPointsRewards, GameRecord, RankingRecordData, ScoreToPoints, DailyGames } from "../codegen/index.sol";

library Utils {
  function getCurrentSeason() internal view returns (uint256, uint256) {
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
  
    // uint256 shortestTime = RankingRecord.getShortestTime(owner);
    // uint256 lastestScores = RankingRecord.getLatestScores(owner) + score;
    // uint256 totalScore = RankingRecord.getTotalScore(owner) + score;
    // uint256 highestScore = RankingRecord.getHighestScore(owner);

    (uint256 csd, uint256 currentSeason) = getCurrentSeason();
    WeeklyRecordData memory weeklyRecordData = WeeklyRecord.get(owner, currentSeason, csd);

    uint256 seasonShortestTime = weeklyRecordData.shortestTime;
    uint256 seasonLastestScores = weeklyRecordData.latestScores + score;
    uint256 seasonTotalScore = weeklyRecordData.totalScore + score;
    uint256 seasonHighestScore = weeklyRecordData.highestScore;

    if(lastestScores >= 250 && !ScoreToPointsRewards.get(owner)){
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
  }

  function getCurrentDayFromDailyGames() internal view returns(uint256) {
    SeasonTimeData memory seasonTimeData = SeasonTime.get(2);
    if (block.timestamp < seasonTimeData.startTime || seasonTimeData.duration == 0) {
      return 0;
    }
    uint256 currentDay = (block.timestamp - seasonTimeData.startTime) / seasonTimeData.duration + 1;
    return currentDay;
  }



}
