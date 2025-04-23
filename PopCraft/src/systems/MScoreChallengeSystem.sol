// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { DefaultParameters, Position } from "../core_codegen/index.sol";
import { TCMPopStar, TCMPopStarData, Token, OverTime, ComboReward, ModeRecord, ModeWeeklyRecord, GameMode, RankingRecord, ScoreChal, ScoreChalData } from "../codegen/index.sol";
import { IERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IERC721 } from "../interfaces/IERC721.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";
import { PopCraftUtils } from "../libraries/PopCraftUtils.sol";

contract MScoreChallengeSystem is System {
  function pop(DefaultParameters memory default_parameters) public {
    Position memory position = default_parameters.position;
    address sender = _msgSender();
    require(GameMode.getMode(sender) == 1, "Mode Error");

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
    if (click_value == 0) revert("Not Star");
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
      uint256 eliminateScore = PopCraftUtils.getEliminateScore(eliminateAmount);
      bool gameSuccess = checkGameSuccess(sender, eliminateScore);
      matrix_array = regenerateBottomRows(sender, matrix_array);

      // game success
      if (gameSuccess) {
        PopCraftUtils.gameSuccess(sender, 1);
      }
      
      tcmPopStarData.gameFinished = gameSuccess;
      tcmPopStarData.matrixArray = matrix_array;
      TCMPopStar.set(sender, tcmPopStarData);

      PopCraftUtils.updateRankRecord(sender, eliminateScore, gameSuccess);
      PopCraftUtils.updatePlayerDailyGames(sender);
      PopCraftUtils.updateStreakDays(sender);
    }
  }

  function checkGameSuccess(address owner, uint256 eliminateScore) public view returns (bool) {
    if (ModeRecord.getLatestScores(owner, 1) + eliminateScore >= 600) {
      return true;
    }
    return false;
  }

  function regenerateBottomRows(address player, uint256[] memory board) private returns (uint256[] memory) {
    ScoreChalData memory scoreChalData = ScoreChal.get(player);
    uint256[] memory newMatrixArray = scoreChalData.newMatrixArray;
    uint256 newMatrixArrayLength = newMatrixArray.length;
    if (newMatrixArray[newMatrixArrayLength - 1] == 0) {
      return board;
    }
    uint256 newValueIndex = findNewValueIndex(newMatrixArray);
    if(newValueIndex == newMatrixArrayLength){
      return board;
    }
    for (uint256 i = 100; i > 0; i--) {
      uint256 index = i - 1;
      if(board[index] == 0){
        if(newValueIndex == newMatrixArrayLength || newMatrixArray[newValueIndex] == 0) break;
        board[index] = newMatrixArray[newValueIndex];
        newMatrixArray[newValueIndex] = 0;
        newValueIndex++;
      }
    }
    ScoreChal.set(player, true, newMatrixArray);
    return board;
  }

  function findNewValueIndex(uint256[] memory newMatrixArray) pure private returns (uint256){
    for (uint256 index = 0; index < newMatrixArray.length; index++) {
      if(newMatrixArray[index] != 0){
        return index;
      }
    }
    return newMatrixArray.length;
  }
}
