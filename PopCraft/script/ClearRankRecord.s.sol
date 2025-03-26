// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
// Create resource identifiers (for the namespace and system)
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { GameRecord, RankingRecord, SeasonTime, StarToScore, GamesRewardsScores, StreakDays, ComboReward, TokenBalance, TokenSoldData, TokenSold } from "../src/codegen/index.sol";
// forge script script/ClearRankRecord.s.sol --rpc-url http://127.0.0.1:8545 --broadcast

contract PopCraftExtension is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address worldAddress = vm.envAddress("WORLD_ADDRESS");
    console.log("world Address: ", worldAddress);

    vm.startBroadcast(deployerPrivateKey);
    StoreSwitch.setStoreAddress(worldAddress);
    // StreakDays.register();
    // ComboReward.register();
    // StarToScore.set(101, 150);
    // SeasonTime.set(1, 1740038400, 1200);

    // forge script script/ClearRankRecord.s.sol --rpc-url https://rpc.morphl2.io --broadcast
    // SeasonTime.set(1, 1740142800, 604800); //1740142800
    // SeasonTime.set(2, 1740747600, 86400); //1740747600
    // SeasonTime.set(3, 1741352400, 604800); //1741352400

    SeasonTime.set(1, 0, 0); //1740142800
    SeasonTime.set(2, 0, 0); //1740747600
    SeasonTime.set(3, 0, 0); //1741352400

    //  1	1740060000	604800
    // 2	1740664800	86400
    // 3	1741269600	604800
    // 4	0	86400
    // 5	1741269600	86400

    // address[10] memory priTokenAddress = [
    //   0x0000000000000000000000000000000000000003,
    //   0x0000000000000000000000000000000000000004,
    //   0x0000000000000000000000000000000000000005,
    //   0x0000000000000000000000000000000000000006,
    //   0x0000000000000000000000000000000000000007,
    //   0x0000000000000000000000000000000000000008,
    //   0x0000000000000000000000000000000000000009,
    //   0x0000000000000000000000000000000000000010,
    //   0x0000000000000000000000000000000000000011,
    //   0x0000000000000000000000000000000000000012
    // ];
    // uint256 rewardTokenAmount = 75 * 10 ** 18;
    // address[1] memory rewardAddress = [
    //   // 0x99FD88012229473B13011c821B24Ebf8AabF82c4,
    //   // 0x392796f95B2398Aa98D55e3dF5967D20F5A97F18,
    //   // 0xb80AF1d22D36A9B03C7725bdd74cabAE8cbB220b,
    //   // 0xDa68a8f7dAdaEd387be410BBD172E8Af4ee383A7
    //   0xD3d0406AE6c6bE123bE80580cD9FbD4d96033DBB

    // ];
    // for (uint256 i = 0; i < rewardAddress.length; i++) {
    //   address player = rewardAddress[i];
    //   for (uint256 j = 0; j < priTokenAddress.length; j++) {
    //     address tokenAddr = priTokenAddress[j];
    //     TokenBalance.set(player, tokenAddr, TokenBalance.get(rewardAddress[i], tokenAddr) + rewardTokenAmount);
    //     TokenSoldData memory tokenSoldData = TokenSold.get(tokenAddr);
    //     TokenSold.set(tokenAddr, tokenSoldData.soldNow + rewardTokenAmount, tokenSoldData.soldAll + rewardTokenAmount);
    //   }
    // }

    // GamesRewardsScores.set(1, 3, 150);
    // GamesRewardsScores.set(1, 5, 350);
    // GamesRewardsScores.set(1, 10, 1000);
    // GamesRewardsScores.set(1, 20, 3000);
    // GamesRewardsScores.set(1, 50, 10000);

    // GamesRewardsScores.set(1, 1, 0);
    // GamesRewardsScores.set(1, 3, 250);
    // GamesRewardsScores.set(1, 5, 500);
    // GamesRewardsScores.set(1, 10, 800);
    // GamesRewardsScores.set(1, 20, 2000);

    vm.stopBroadcast();
  }
}
