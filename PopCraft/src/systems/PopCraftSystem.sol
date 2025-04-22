// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { DefaultParameters, Position, UniversalRouterParams } from "../core_codegen/index.sol";
import { TCMPopStar, TCMPopStarData, GameRecord, GameRecordData, RankingRecord, OverTime, WeeklyRecord, WeeklyRecordData, ScoreToPointsRewards, DailyGames, GameMode, ModeRecord, ModeWeeklyRecord, RankingRecordData, ScoreChal, ScoreChal } from "../codegen/index.sol";
import { IERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IERC721 } from "../interfaces/IERC721.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";
import { PopCraftUtils } from "../libraries/PopCraftUtils.sol";

contract PopCraftSystem is System {
  receive() external payable {}

  function interact(DefaultParameters memory default_parameters, uint256 mode) public {
    Position memory position = default_parameters.position;
    address owner = _msgSender();
    TCMPopStarData memory tcmPopStarData = TCMPopStar.get(owner);

    if (tcmPopStarData.startTime > 0) {
      position = Position({ x: tcmPopStarData.x, y: tcmPopStarData.y });
    }
    require(mode < 2, "Mode Error");

    uint256 timestamp = block.timestamp;
    uint256[] memory matrix = PopCraftUtils.shuffle(owner, 100);
    address[] memory tokenAddressArr = PopCraftUtils.randomTCMToken();

    TCMPopStar.set(owner, position.x, position.y, timestamp, false, matrix, tokenAddressArr);

    createGameInitRecord(mode, owner);
    PopCraftUtils.updateComboRewardGames(owner);
  }

  function createGameInitRecord(uint256 mode, address owner) private {
    GameMode.set(owner, mode);
    GameRecordData memory gameRecordData = GameRecord.get(owner);

    if (ModeRecord.getTimes(owner, 0) == 0 && ModeRecord.getTimes(owner, 1) == 0) {
      RankingRecordData memory rankingRecordData = RankingRecord.get(owner);
      ModeRecord.set(
        owner,
        0,
        rankingRecordData.totalScore,
        rankingRecordData.highestScore,
        rankingRecordData.latestScores,
        rankingRecordData.shortestTime,
        gameRecordData.times,
        gameRecordData.successTimes,
        gameRecordData.totalPoints
      );
    }

    GameRecord.setTimes(owner, gameRecordData.times + 1);
    RankingRecord.setLatestScores(owner, 0);
    ModeRecord.setTimes(owner, mode, ModeRecord.getTimes(owner, mode) + 1);
    ModeRecord.setLatestScores(owner, mode, 0);

    if (ScoreToPointsRewards.get(owner)) {
      ScoreToPointsRewards.set(owner, false);
    }

    if (DailyGames.getAdded(owner)) {
      DailyGames.setAdded(owner, false);
    }

    (uint256 csd, uint256 currentSeason) = Utils.getCurrentSeason();
    if (csd > 0 && currentSeason > 0) {
      WeeklyRecordData memory weeklyRecordData = WeeklyRecord.get(owner, currentSeason, csd);
      WeeklyRecord.setTimes(owner, currentSeason, csd, weeklyRecordData.times + 1);
      WeeklyRecord.setLatestScores(owner, currentSeason, csd, 0);
      if (ModeWeeklyRecord.getTimes(owner, currentSeason, csd, 0) == 0 && ModeWeeklyRecord.getTimes(owner, currentSeason, csd, 1) == 0 && weeklyRecordData.times != 0) {
        ModeWeeklyRecord.set(
          owner,
          currentSeason,
          csd,
          0,
          weeklyRecordData.totalScore,
          weeklyRecordData.highestScore,
          weeklyRecordData.latestScores,
          weeklyRecordData.shortestTime,
          weeklyRecordData.times,
          weeklyRecordData.successTimes,
          weeklyRecordData.totalPoints
        );
      }
      ModeWeeklyRecord.setTimes(
        owner,
        currentSeason,
        csd,
        mode,
        ModeWeeklyRecord.getTimes(owner, currentSeason, csd, mode) + 1
      );
      ModeWeeklyRecord.setLatestScores(owner, currentSeason, csd, mode, 0);
    }
    if(mode == 1){
      uint256[] memory newBottomArr = PopCraftUtils.shuffle(owner, 30);
      ScoreChal.set(owner, false, newBottomArr);
    }
  }

  // function withDrawToken(address[] memory token_addr, uint256[] memory amount) public pure {
  // uint256 token_addr_length = token_addr.length;
  // require(token_addr_length == amount.length, 'Length mismatch');
  // for(uint256 i; i < token_addr_length; i++){
  //   uint256 token_balance = TokenBalance.get(_msgSender(), token_addr[i]);
  //   if(token_balance < amount[i]) revert InsufficientBalance(token_addr[i]);

  //   uint256 token_sold_now = TokenSold.getSoldNow(token_addr[i]);
  //   TokenSold.setSoldNow(token_addr[i], token_sold_now - amount[i]);
  //   TokenBalance.set(_msgSender(), token_addr[i], token_balance - amount[i]);

  //   IWorld(_world()).transferERC20TokenToAddress(WorldResourceIdLib.encodeNamespace(BYTESNAMESPACE), token_addr[i], _msgSender(), amount[i]);
  // }
  // }
}
