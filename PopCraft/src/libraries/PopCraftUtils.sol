// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Token } from "../codegen/index.sol";
import { WeeklyRecord, RankingRecord, StarToScore, WeeklyRecordData, TCMPopStar, ScoreToPointsRewards, GameRecord, RankingRecordData, ScoreToPoints, DailyGames, ModeRecord, ModeWeeklyRecord, GameMode, TokenBalance, TokenSold, ComboReward, TokenSoldData, DailyGamesData, StreakDaysData, StreakDays, ComboRewardGamesData, ModeRecordData, ComboRewardGames, ModeWeeklyRecordData, GameRecordData, GameRecordData, GameRecordData } from "../codegen/index.sol";
import { IERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20.sol";
import { Check } from "./Check.sol";
import { Utils } from "./Check.sol";
import { Invite } from "./Invite.sol";

library PopCraftUtils {
  error InsufficientBalance(address);
  function shuffle(address sender, uint256 length) public view returns (uint256[] memory) {
    uint256[] memory matrix = new uint256[](length);
    for (uint256 i = 0; i < length; ) {
      uint256 random_num = (uint256(keccak256(abi.encodePacked(sender, block.timestamp, block.number, i, length))) % 5) + 1;
      matrix[i] = random_num;
      unchecked {
        i++;
      }
    }
    return matrix;
  }

  function randomTCMToken() public view returns (address[] memory) {
    address[] memory address_arr = new address[](5);
    address[] memory tempValues = Token.get(0);
    uint256 n = tempValues.length;

    // Fisher-Yates shuffle
    for (uint256 i = 0; i < 5; i++) {
      uint256 randIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, i))) % n;
      address_arr[i] = tempValues[randIndex];
      tempValues[randIndex] = tempValues[n - 1];
      n--;
    }
    address KOALA = 0x0000000000000000000000000000000000000012;
    for (uint256 i = 0; i < 5; i++) {
      if (address_arr[i] == KOALA) {
        break;
      } else {
        if (i == 4) {
          address_arr[i] = KOALA;
        }
      }
    }
    return address_arr;
  }

  function useToken(address token_addr, address player) internal {
    uint256 token_balance = TokenBalance.get(player, token_addr);
    uint8 token_decimals;
    if (Check.checkIsPriToken(token_addr)) {
      token_decimals = 18;
    } else {
      token_decimals = IERC20(token_addr).decimals();
    }
    uint256 deduct_token_num = 10 ** uint256(token_decimals);

    if (token_balance < deduct_token_num) revert InsufficientBalance(token_addr);

    uint256 token_sold_now = TokenSold.getSoldNow(token_addr);
    TokenSold.setSoldNow(token_addr, token_sold_now - deduct_token_num);

    TokenBalance.set(player, token_addr, token_balance - deduct_token_num);
  }

  function comboReward(uint256 eliminateAmount, address tokenAddr, address player) internal {
    bool eligibility = Check.checkComboRewardEligibility(player);
    if (eliminateAmount >= 5 && eligibility && Check.checkIsPriToken(tokenAddr)) {
      uint256 amount = eliminateAmount / 5;
      // add new token: change here
      uint256 rewardTokenAmount = amount * 10 ** 18;
      ComboReward.set(player, tokenAddr, ComboReward.get(player, tokenAddr) + rewardTokenAmount);
      TokenBalance.set(player, tokenAddr, TokenBalance.get(player, tokenAddr) + rewardTokenAmount);
      TokenSoldData memory tokenSoldData = TokenSold.get(tokenAddr);
      TokenSold.set(tokenAddr, tokenSoldData.soldNow + rewardTokenAmount, tokenSoldData.soldAll + rewardTokenAmount);
    }
  }

  function move(uint256[] memory matrix_array) internal pure returns (uint256[] memory) {
    uint256 index;
    uint256 zero_index_row;
    uint256 zero_index_col_bot = 89;
    uint256 zero_index_col;

    for (uint256 i; i < 10; ) {
      zero_index_row = 90 + i;
      for (uint256 j = 10; j > 0; ) {
        unchecked {
          j--;
          index = i + j * 10;
          if (matrix_array[index] != 0) {
            if (index != zero_index_row) {
              matrix_array[zero_index_row] = matrix_array[index];
              matrix_array[index] = 0;
            }
            zero_index_row -= 10;
          }
        }
      }

      if (i > 0 && matrix_array[zero_index_col_bot] == 0) {
        if (matrix_array[90 + i] != 0) {
          zero_index_col = zero_index_col_bot - 90;
          for (uint256 x = 0; x < 10; ) {
            index = i + x * 10;
            if (matrix_array[index] != 0) {
              matrix_array[x * 10 + zero_index_col] = matrix_array[index];
              matrix_array[index] = 0;
            }
            unchecked {
              x++;
            }
          }
          zero_index_col_bot += 1;
        }
      } else {
        zero_index_col_bot += 1;
      }
      unchecked {
        i++;
      }
    }
    return matrix_array;
  }

  function updatePlayerDailyGames(address player) internal {
    DailyGamesData memory dailyGamesData = DailyGames.get(player);

    if (dailyGamesData.added || RankingRecord.getLatestScores(player) < 200) {
      return;
    }
    uint256 currentDay = Utils.getCurrentDayFromDailyGames();
    if (currentDay == 0) {
      return;
    }
    uint256 games = dailyGamesData.games;
    uint256 day = dailyGamesData.day;
    uint256 received = dailyGamesData.received;
    if (day == currentDay) {
      games += 1;
    } else {
      games = 1;
      day = currentDay;
      received = 0;
    }
    DailyGames.set(player, games, day, received, true);
  }

  function updateStreakDays(address player) internal {
    if (RankingRecord.getLatestScores(player) < 200) {
      return;
    }

    StreakDaysData memory streakDaysData = StreakDays.get(player);
    (uint256 totalCycleTimes, uint256 timesInCurrentCycle) = Utils.getCurrentSteakDayData();
    if (
      totalCycleTimes == 0 ||
      timesInCurrentCycle == 0 ||
      (streakDaysData.addedDays == timesInCurrentCycle && streakDaysData.addedCycle == totalCycleTimes)
    ) {
      return;
    }

    uint256 times = streakDaysData.times;
    uint256 received = streakDaysData.received;
    if (totalCycleTimes == streakDaysData.cycle && timesInCurrentCycle - streakDaysData.addedDays == 1) {
      times += 1;
      streakDaysData.totalTimes += 1;
    } else {
      times = 1;
      received = 0;
      if (totalCycleTimes - streakDaysData.cycle == 1 && timesInCurrentCycle == 1) {
        streakDaysData.totalTimes += 1;
      } else {
        streakDaysData.totalTimes = 1;
      }
    }
    StreakDays.set(
      player,
      times,
      streakDaysData.totalTimes,
      received,
      streakDaysData.totalReceived,
      totalCycleTimes,
      totalCycleTimes,
      timesInCurrentCycle
    );
  }

  function updateComboRewardGames(address player) internal {
    uint256 currentDay = Utils.getCurrentDayCommon(5);
    if (currentDay == 0) {
      return;
    }
    ComboRewardGamesData memory comboRewardGamesData = ComboRewardGames.get(player);
    if (comboRewardGamesData.addedTime == currentDay) {
      ComboRewardGames.setGames(player, comboRewardGamesData.games + 1);
    } else {
      ComboRewardGames.set(player, 1, currentDay);
    }
  }

  function updateRankRecord(address owner, uint256 score, bool game_success) internal {
    uint256 mode = GameMode.getMode(owner);

    RankingRecordData memory rankingRecordData = RankingRecord.get(owner);
    rankingRecordData.latestScores += score;
    rankingRecordData.totalScore += score;

    ModeRecordData memory modeRecordData = ModeRecord.get(owner, mode);
    modeRecordData.latestScores += score;
    modeRecordData.totalScore += score;

    (uint256 csd, uint256 currentSeason) = Utils.getCurrentSeason();
    WeeklyRecordData memory weeklyRecordData = WeeklyRecord.get(owner, currentSeason, csd);
    weeklyRecordData.latestScores += score;
    weeklyRecordData.totalScore += score;

    ModeWeeklyRecordData memory modeWeeklyRecordData = ModeWeeklyRecord.get(owner, currentSeason, csd, mode);
    modeWeeklyRecordData.latestScores += score;
    modeWeeklyRecordData.totalScore += score;

    if (rankingRecordData.latestScores >= 250 && !ScoreToPointsRewards.get(owner)) {
      uint256 pointsRewards = ScoreToPoints.get(250);

      GameRecord.setTotalPoints(owner, GameRecord.getTotalPoints(owner) + pointsRewards);
      weeklyRecordData.totalPoints += pointsRewards;
      modeRecordData.totalPoints += pointsRewards;
      modeWeeklyRecordData.totalPoints += pointsRewards;

      ScoreToPointsRewards.set(owner, true);
    }

    if (game_success) {
      uint256 successScore = StarToScore.get(101);
      score += successScore;
      rankingRecordData.totalScore += successScore;
      rankingRecordData.latestScores += successScore;

      modeRecordData.totalScore += successScore;
      modeRecordData.latestScores += successScore;

      weeklyRecordData.totalScore += successScore;
      weeklyRecordData.latestScores += successScore;

      modeWeeklyRecordData.totalScore += successScore;
      modeWeeklyRecordData.latestScores += successScore;

      uint256 startTime = TCMPopStar.getStartTime(owner);
      uint256 successTime = block.timestamp - startTime;

      if (successTime < rankingRecordData.shortestTime || rankingRecordData.shortestTime == 0) {
        rankingRecordData.shortestTime = successTime;
        modeRecordData.shortestTime = successTime;
      }

      if (successTime < modeRecordData.shortestTime || modeRecordData.shortestTime == 0) {
        modeRecordData.shortestTime = successTime;
      }

      if (successTime < weeklyRecordData.shortestTime || weeklyRecordData.shortestTime == 0) {
        weeklyRecordData.shortestTime = successTime;
      }

      if (successTime < modeWeeklyRecordData.shortestTime || modeWeeklyRecordData.shortestTime == 0) {
        modeWeeklyRecordData.shortestTime = successTime;
      }
    }

    if (rankingRecordData.latestScores > rankingRecordData.highestScore) {
      rankingRecordData.highestScore = rankingRecordData.latestScores;
    }

    if (weeklyRecordData.latestScores > weeklyRecordData.highestScore) {
      weeklyRecordData.highestScore = weeklyRecordData.latestScores;
    }

    if (modeRecordData.latestScores > modeRecordData.highestScore) {
      modeRecordData.highestScore = modeRecordData.latestScores;
    }

    if (modeWeeklyRecordData.latestScores > modeWeeklyRecordData.highestScore) {
      modeWeeklyRecordData.highestScore = modeWeeklyRecordData.latestScores;
    }

    RankingRecord.set(owner, rankingRecordData);
    ModeRecord.set(owner, mode, modeRecordData);

    if (csd > 0 && currentSeason > 0) {
      WeeklyRecord.set(owner, currentSeason, csd, weeklyRecordData);
      ModeWeeklyRecord.set(owner, currentSeason, csd, mode, modeWeeklyRecordData);
    }
    Invite.addInviteScores(score, owner, csd, currentSeason);
  }

  function getEliminateScore(uint256 eliminateAmount) public view returns (uint256) {
    uint256 score;

    if (eliminateAmount > 5) {
      score = StarToScore.get(5) + StarToScore.get(0) * (eliminateAmount - 5);
    } else {
      score = StarToScore.get(eliminateAmount);
    }
    return score;
  }

  function gameSuccess(address player, uint256 mode) internal {
    GameRecordData memory gameRecordData = GameRecord.get(player);
    gameRecordData.unissuedRewards += 1;
    GameRecord.set(
      player,
      gameRecordData.times,
      gameRecordData.successTimes += 1,
      gameRecordData.unissuedRewards,
      gameRecordData.totalPoints + 100
    );

    ModeRecordData memory modeRecordData = ModeRecord.get(player, mode);
    modeRecordData.successTimes += 1;
    modeRecordData.totalPoints += 100;
    ModeRecord.set(player, mode, modeRecordData);

    (uint256 csd, uint256 currentSeason) = Utils.getCurrentSeason();
    if (csd > 0 && currentSeason > 0) {
      WeeklyRecordData memory weeklyRecordData = WeeklyRecord.get(player, currentSeason, csd);
      WeeklyRecord.setSuccessTimes(player, currentSeason, csd, weeklyRecordData.successTimes + 1);
      WeeklyRecord.setTotalPoints(player, currentSeason, csd, weeklyRecordData.totalPoints + 100);

      ModeWeeklyRecordData memory modeWeeklyRecordData = ModeWeeklyRecord.get(player, currentSeason, csd, mode);
      modeWeeklyRecordData.successTimes += 1;
      modeWeeklyRecordData.totalPoints += 100;
      ModeWeeklyRecord.set(player, currentSeason, csd, mode, modeWeeklyRecordData);
    }
  }
}
