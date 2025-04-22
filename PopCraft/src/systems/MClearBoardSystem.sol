// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { DefaultParameters, Position, UniversalRouterParams } from "../core_codegen/index.sol";
import { TCMPopStar, TCMPopStarData, GameRecord, GameRecordData, RankingRecord, OverTime, WeeklyRecord, WeeklyRecordData, ScoreToPointsRewards, DailyGames, GameMode, ModeRecord, ModeWeeklyRecord, RankingRecordData } from "../codegen/index.sol";
import { IERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IERC721 } from "../interfaces/IERC721.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";
import { PopCraftUtils } from "../libraries/PopCraftUtils.sol";

contract MClearBoardSystem is System {

  function pop(DefaultParameters memory default_parameters) public {
    Position memory position = default_parameters.position;
    address sender = address(_msgSender());
    require(GameMode.getMode(sender) == 0, "Not Classic Mode");

    TCMPopStarData memory tcmPopStarData = TCMPopStar.get(sender);
    require(!tcmPopStarData.gameFinished, "Game Over");
    uint256 overtime = OverTime.get(0) * 1 seconds;

    if (block.timestamp > (tcmPopStarData.startTime + overtime)) {
      TCMPopStar.setGameFinished(sender, true);
      return;
    }

    uint256[] memory matrix_array = tcmPopStarData.matrixArray;
    // click num index in matrix
    uint256 matrix_index = (position.x - tcmPopStarData.x) + (position.y - tcmPopStarData.y) * 10;
    // click num value
    uint256 click_value = matrix_array[matrix_index];
    if (click_value == 0) revert("Please click on the star");
    uint256 eliminateAmount;

    bool pop_access = Check.check_pop_access(matrix_index, click_value, matrix_array);
    address token_addr = tcmPopStarData.tokenAddressArr[click_value - 1];

    if (!pop_access) {
      {
        PopCraftUtils.useToken(token_addr, sender);

        matrix_array[matrix_index] = 0;
        eliminateAmount = 1;
      }
    } else {
      (matrix_array, eliminateAmount) = Utils.dfs(matrix_index, click_value, matrix_array, eliminateAmount);
      PopCraftUtils.comboReward(eliminateAmount, token_addr, sender);
    }

    matrix_array = PopCraftUtils.move(matrix_array);

    {
      bool gameSuccess = checkGameSuccess(matrix_array);

      TCMPopStar.set(
        sender,
        tcmPopStarData.x,
        tcmPopStarData.y,
        tcmPopStarData.startTime,
        gameSuccess,
        matrix_array,
        tcmPopStarData.tokenAddressArr
      );

      // game success
      if (gameSuccess) {
        PopCraftUtils.gameSuccess(sender, 0);
      } 

      PopCraftUtils.updateRankRecord(sender, PopCraftUtils.getEliminateScore(eliminateAmount), gameSuccess);
      PopCraftUtils.updatePlayerDailyGames(sender);
      PopCraftUtils.updateStreakDays(sender);
    }
  }

  function checkGameSuccess(uint256[] memory matrix_array) public pure returns (bool) {
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
  
}
