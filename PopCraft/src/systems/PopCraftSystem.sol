// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { ICoreSystem } from "../core_codegen/world/ICoreSystem.sol";
import { IWorld } from "../core_codegen/world/IWorld.sol";
import { PermissionsData, DefaultParameters, Position, PixelUpdateData, Pixel, PixelData, ERC20TokenBalance, UniversalRouterParams, TokenInfo } from "../core_codegen/index.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { TCMPopStar, TCMPopStarData, TokenBalance, TokenSold, TokenSoldData, GameRecord, GameRecordData, StarToScore, DayToScore, RankingRecord, Token, OverTime, UserBenefitsToken, ComboReward, WeeklyRecord, WeeklyRecordData, ScoreToPointsRewards, DailyGames, DailyGamesData } from "../codegen/index.sol";
import { IERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { Puppet } from "@latticexyz/world-modules/src/modules/puppet/Puppet.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IQuote, SwapParams, Quote } from "../interfaces/IQuote.sol";
import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";
import { PopCraftUtils } from "../libraries/PopCraftUtils.sol";

contract PopCraftSystem is System {
  // string constant APP_ICON = "U+1F48E";
  // string constant NAMESPACE = "popCraft";
  // string constant SYSTEM_NAME = "PopCraftSystem";
  // string constant APP_NAME = "PopCraft";
  // string constant APP_MANIFEST = "BASE/PopCraftSystem";
  // bytes14 constant BYTESNAMESPACE = bytes14(bytes(NAMESPACE));

  error InsufficientBalance(address);

  receive() external payable {}

  // function init() public {
  //   ICoreSystem(_world()).update_app(APP_NAME, APP_ICON, APP_MANIFEST, NAMESPACE, SYSTEM_NAME);
  // }

  function interact(DefaultParameters memory default_parameters) public {
    Position memory position = default_parameters.position;
    address owner = _msgSender();
    TCMPopStarData memory tcmPopStarData = TCMPopStar.get(owner);

    if (tcmPopStarData.startTime > 0) {
      position = Position({ x: tcmPopStarData.x, y: tcmPopStarData.y });
    }

    {
      uint256 timestamp = block.timestamp;
      uint256[] memory matrix = PopCraftUtils.shuffle(owner);
      address[] memory tokenAddressArr = PopCraftUtils.randomTCMToken();

      TCMPopStar.set(owner, position.x, position.y, timestamp, false, matrix, tokenAddressArr);
      uint256 gameTimes = GameRecord.getTimes(owner);
      GameRecord.setTimes(owner, gameTimes += 1);
      RankingRecord.setLatestScores(owner, 0);
      ScoreToPointsRewards.set(owner, false);
      DailyGames.setAdded(owner, false);
      
      (uint256 csd, uint256 currentSeason) = Utils.getCurrentSeason();
      if (csd > 0 && currentSeason > 0) {
        uint256 currentSeasonGameTimes = WeeklyRecord.getTimes(owner, currentSeason, csd);
        WeeklyRecord.setTimes(owner, currentSeason, csd, currentSeasonGameTimes + 1);
        WeeklyRecord.setLatestScores(owner, currentSeason, csd, 0);
      }
    }
  }

  function shuffle() private view returns (uint256[] memory) {
    uint256[] memory matrix = new uint256[](100);
    address sender = _msgSender();
    for (uint256 i = 0; i < 100; ) {
      uint256 random_num = (uint256(keccak256(abi.encodePacked(sender, block.timestamp, block.number, i))) % 5) + 1;
      matrix[i] = random_num;
      unchecked {
        i++;
      }
    }
    return matrix;
  }

  function randomTCMToken() private view returns (address[] memory) {
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

  function pop(DefaultParameters memory default_parameters) public {
    Position memory position = default_parameters.position;
    address sender = address(_msgSender());

    TCMPopStarData memory tcmPopStarData = TCMPopStar.get(sender);
    require(!tcmPopStarData.gameFinished, "Game Over");
    uint256 overtime = OverTime.get(0) * 1 seconds;

    if (block.timestamp > (tcmPopStarData.startTime + overtime)) {
      TCMPopStar.set(
        sender,
        tcmPopStarData.x,
        tcmPopStarData.y,
        tcmPopStarData.startTime,
        true,
        tcmPopStarData.matrixArray,
        tcmPopStarData.tokenAddressArr
      );

      return;
    }

    uint256[] memory matrix_array = tcmPopStarData.matrixArray;
    // click num index in matrix
    uint256 matrix_index = (position.x - tcmPopStarData.x) + (position.y - tcmPopStarData.y) * 10;
    // click num value
    uint256 click_value = matrix_array[matrix_index];
    if (click_value == 0) revert("Please click on the star");
    uint256 eliminate_amount;

    bool pop_access = check_pop_access(matrix_index, click_value, matrix_array);
    address token_addr = tcmPopStarData.tokenAddressArr[click_value - 1];

    if (!pop_access) {
      {
        _useToken(token_addr);

        matrix_array[matrix_index] = 0;
        eliminate_amount = 1;
      }
    } else {
      (matrix_array, eliminate_amount) = dfs(matrix_index, click_value, matrix_array, eliminate_amount);
      comboReward(eliminate_amount, token_addr);
    }

    matrix_array = move(matrix_array);

    {
      bool game_finished = check_game_finished(matrix_array);

      TCMPopStar.set(
        sender,
        tcmPopStarData.x,
        tcmPopStarData.y,
        tcmPopStarData.startTime,
        game_finished,
        matrix_array,
        tcmPopStarData.tokenAddressArr
      );

      // game success
      if (game_finished) {
        _gameFinished();
        Utils.updateRankRecord(sender, eliminate_amount, true);
      } else {
        Utils.updateRankRecord(sender, eliminate_amount, false);
      }
      updatePlayerDailyGames();
    }
  }

  function _gameFinished() private {
    address sender = _msgSender();
    GameRecordData memory gameRecordData = GameRecord.get(sender);
    gameRecordData.unissuedRewards += 1;
    GameRecord.set(
      sender,
      gameRecordData.times,
      gameRecordData.successTimes += 1,
      gameRecordData.unissuedRewards,
      gameRecordData.totalPoints + 100
    );

    (uint256 csd, uint256 currentSeason) = Utils.getCurrentSeason();
    if (csd > 0 && currentSeason > 0) {
      WeeklyRecordData memory weeklyRecordData = WeeklyRecord.get(sender, currentSeason, csd);
      WeeklyRecord.setSuccessTimes(sender, currentSeason, csd, weeklyRecordData.successTimes + 1);
      WeeklyRecord.setTotalPoints(sender, currentSeason, csd, weeklyRecordData.totalPoints + 100);
    }
  }

  function _useToken(address token_addr) private {
    address sender = _msgSender();
    uint256 token_balance = TokenBalance.get(sender, token_addr);
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

    TokenBalance.set(sender, token_addr, token_balance - deduct_token_num);
  }

  function dfs(
    uint256 matrix_index,
    uint256 target_value,
    uint256[] memory matrix_array,
    uint256 eliminate_amount
  ) private returns (uint256[] memory, uint256) {
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

  function comboReward(uint256 eliminateAmount, address tokenAddr) private {
    if (eliminateAmount >= 5) {
      uint256 amount = eliminateAmount / 5;
      // add new token: change here
      uint256 rewardTokenAmount = amount * 10 ** 18;
      address sender = _msgSender();
      ComboReward.set(sender, tokenAddr, ComboReward.get(sender, tokenAddr) + rewardTokenAmount);
      TokenBalance.set(sender, tokenAddr, TokenBalance.get(sender, tokenAddr) + rewardTokenAmount);
      TokenSoldData memory tokenSoldData = TokenSold.get(tokenAddr);
      TokenSold.set(tokenAddr, tokenSoldData.soldNow + rewardTokenAmount, tokenSoldData.soldAll + rewardTokenAmount);
    }
  }

  function move(uint256[] memory matrix_array) private pure returns (uint256[] memory) {
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
    // for(uint256 i; i < 10; ){

    // }
    return matrix_array;
  }

  function check_pop_access(
    uint256 matrix_index,
    uint256 target_value,
    uint256[] memory matrix_array
  ) private pure returns (bool) {
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

  function check_game_finished(uint256[] memory matrix_array) private pure returns (bool) {
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

  function converToBytes32(string memory input) private pure returns (bytes32) {
    bytes memory stringBytes = bytes(input);
    if (stringBytes.length == 0) {
      return 0x0;
    }
    bytes32 result;
    assembly {
      result := mload(add(stringBytes, 32))
    }
    return result;
  }

  function buyToken(UniversalRouterParams[] calldata universalRouterParams) public payable {
    uint256 router_params_length = universalRouterParams.length;

    require(_msgValue() > 0, "msgValue < 0");
    (
      UniversalRouterParams[] memory resultParams,
      uint256 value,
      UniversalRouterParams[] memory priResultParams,
      uint256 valuePri
    ) = Check.dealUniversalRouterParams(universalRouterParams);
    require(_msgValue() >= value + valuePri, "Insufficient");
    Check.checkPriTokenPirce(priResultParams, valuePri);

    require(resultParams.length == 0, "token > 0");

    for (uint256 i; i < router_params_length; i++) {
      address token_addr = universalRouterParams[i].token_info.token_addr;
      uint256 amount = universalRouterParams[i].token_info.amount;

      TokenSoldData memory tokenSoldData = TokenSold.get(token_addr);
      TokenSold.set(token_addr, tokenSoldData.soldNow + amount, tokenSoldData.soldAll + amount);

      uint256 balance = TokenBalance.get(_msgSender(), token_addr);
      TokenBalance.set(_msgSender(), token_addr, balance + amount);
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

  function getUserBenefitsToken() public {
    address user = _msgSender();

    require(!UserBenefitsToken.get(user), "Already obtained");

    UserBenefitsToken.set(user, true);
    address[] memory priTokenAddr = Token.get(1);
    uint256 priTokenAddrLength = priTokenAddr.length;
    uint256 benefitsAmount = 2 * 10 ** 18;
    for (uint256 i; i < priTokenAddrLength; i++) {
      address tokenAddr = priTokenAddr[i];
      TokenBalance.set(user, tokenAddr, TokenBalance.get(user, tokenAddr) + benefitsAmount);

      TokenSoldData memory tokenSoldData = TokenSold.get(tokenAddr);
      TokenSold.set(tokenAddr, tokenSoldData.soldNow + benefitsAmount, tokenSoldData.soldAll + benefitsAmount);
    }
  }

  function updatePlayerDailyGames() private {
    
    address player = _msgSender();
    DailyGamesData memory dailyGamesData = DailyGames.get(player);
    
    if(dailyGamesData.added || RankingRecord.getLatestScores(player) < 200){
      return;
    }
    uint256 currentDay = Utils.getCurrentDayFromDailyGames();
    if(currentDay == 0){
      return;
    }
    uint256 games = dailyGamesData.games;
    uint256 day = dailyGamesData.day;
    uint256 received = dailyGamesData.received;
    if(day == currentDay){
      games += 1;
    }else{
      games = 1;
      day = currentDay;
      received = 0;
    }
    DailyGames.set(player, games, day, received, true);
  }
}
