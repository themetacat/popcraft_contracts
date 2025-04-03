// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { DailyGames, DailyGamesData, GamesRewardsScores, WeeklyRecord, RankingRecord, StreakDays, StreakDaysData } from "../codegen/index.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";
import { Invite } from "../libraries/Invite.sol";

contract MissionSystem is System {
  function getDailyGamesRewards() public {
    address player = _msgSender();
    DailyGamesData memory dailyGamesData = DailyGames.get(player);

    uint256 currentDay = Utils.getCurrentDayFromDailyGames();
    require(currentDay == dailyGamesData.day, "Not eligible");

    uint256 games = dailyGamesData.games;
    uint256 received = dailyGamesData.received;

    if (games > 50) {
      games = 50;
    }
    require(games > received, "Received");

    uint256 scores;
    for (uint256 i = received + 1; i <= games; i++) {
      scores += GamesRewardsScores.get(1, i);
    }
    RankingRecord.setTotalScore(player, RankingRecord.getTotalScore(player) + scores);
    (uint256 csd, uint256 currentSeason) = Utils.getCurrentSeason();
    if(csd > 0 && currentSeason > 0){
        WeeklyRecord.setTotalScore(player, currentSeason, csd, WeeklyRecord.getTotalScore(player, currentSeason, csd) + scores);
    }
    DailyGames.setReceived(player, games);
    Invite.addInviteScores(scores, player, csd, currentSeason);
  }

  function getStreakDaysRewards() public {
    address player = _msgSender();
    StreakDaysData memory streakDaysData = StreakDays.get(player);

    (uint256 totalCycleTimes, uint256 timesInCurrentCycle) = Utils.getCurrentSteakDayData();
    require(totalCycleTimes == streakDaysData.cycle && timesInCurrentCycle - streakDaysData.addedDays <= 1, "Not eligible");

    uint256 times = streakDaysData.times;
    uint256 received = streakDaysData.received;

    if (times > 7) {
      times = 7;
    }
    require(times > received, "Received");

    uint256 scores;
    for (uint256 i = received + 1; i <= times; i++) {
      scores += GamesRewardsScores.get(2, i);
    }
    RankingRecord.setTotalScore(player, RankingRecord.getTotalScore(player) + scores);
    (uint256 csd, uint256 currentSeason) = Utils.getCurrentSeason();
    if(csd > 0 && currentSeason > 0){
        WeeklyRecord.setTotalScore(player, currentSeason, csd, WeeklyRecord.getTotalScore(player, currentSeason, csd) + scores);
    }
    StreakDays.setReceived(player, times);
    Invite.addInviteScores(scores, player, csd, currentSeason);
  }

  // function getStreakDaysTotalRewards() public {
  //   address player = _msgSender();
  //   StreakDaysData memory streakDaysData = StreakDays.get(player);

  //   uint256 times = streakDaysData.totalTimes;
  //   uint256 received = streakDaysData.totalReceived;

  //   require(times > received, "Received");

  //   uint256 scores;
  //   for (uint256 i = received + 1; i <= times; i++) {
  //     scores += GamesRewardsScores.get(3, i);
  //   }
  //   RankingRecord.setTotalScore(player, RankingRecord.getTotalScore(player) + scores);
  //   (uint256 csd, uint256 currentSeason) = Utils.getCurrentSeason();
  //   if(csd > 0 && currentSeason > 0){
  //       WeeklyRecord.setTotalScore(player, currentSeason, csd, WeeklyRecord.getTotalScore(player, currentSeason, csd) + scores);
  //   }
  //   StreakDays.setTotalReceived(player, times);
  // }
}
