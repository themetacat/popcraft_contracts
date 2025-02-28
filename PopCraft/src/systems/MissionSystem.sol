// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { DailyGames, DailyGamesData, GamesRewardsScores, WeeklyRecord, RankingRecord } from "../codegen/index.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";

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
  }
}
