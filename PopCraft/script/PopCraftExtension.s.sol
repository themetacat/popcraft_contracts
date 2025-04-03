// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;
 
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IBaseWorld } from "@latticexyz/world-modules/src/interfaces/IBaseWorld.sol";
 
import { WorldRegistrationSystem } from "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
 import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
// Create resource identifiers (for the namespace and system)
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
 
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { DefaultParameters } from "../src/core_codegen/index.sol";
import { TCMPopStar, GameRecord, TokenSold, TokenBalance, StarToScore, DayToScore, RankingRecord, Token, OverTime, PriTokenPrice, UserBenefitsToken, ComboReward, SeasonTime, CurrentSeasonDimension, WeeklyRecord, ScoreToPoints, ScoreToPointsRewards, ComboRewardGames, NFTToTokenDiscount } from "../src/codegen/index.sol";
// import { TokenSold } from "../src/codegen/index.sol";
// import { TokenBalance } from "../src/codegen/index.sol";
import { PopCraftSystem } from "../src/systems/PopCraftSystem.sol";
import { Puppet } from "@latticexyz/world-modules/src/modules/puppet/Puppet.sol";

contract PopCraftExtension is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address worldAddress = vm.envAddress("WORLD_ADDRESS");
    console.log("world Address: ", worldAddress);
 
    WorldRegistrationSystem world = WorldRegistrationSystem(worldAddress);
    ResourceId namespaceResource = WorldResourceIdLib.encodeNamespace(bytes14("popCraft"));
    ResourceId systemResource = WorldResourceIdLib.encode(RESOURCE_SYSTEM, "popCraft", "PopCraftSystem");
    console.log("Namespace ID: %x", uint256(ResourceId.unwrap(namespaceResource)));
    console.log("System ID:    %x", uint256(ResourceId.unwrap(systemResource)));

    vm.startBroadcast(deployerPrivateKey);
    world.registerNamespace(namespaceResource);

    StoreSwitch.setStoreAddress(worldAddress);

    TCMPopStar.register();
    TokenSold.register();
    TokenBalance.register();
    GameRecord.register();
    StarToScore.register();
    DayToScore.register();
    RankingRecord.register();
    Token.register();
    OverTime.register();
    PriTokenPrice.register();
    ComboReward.register();
    ScoreToPointsRewards.register();
    SeasonTime.register();
    CurrentSeasonDimension.register();
    WeeklyRecord.register();
    ScoreToPoints.register();
    ComboRewardGames.register();
    NFTToTokenDiscount.register();

    NFTToTokenDiscount.set(0, 4);
    NFTToTokenDiscount.set(1, 10);
    NFTToTokenDiscount.set(2, 20);
    NFTToTokenDiscount.set(3, 30);
    NFTToTokenDiscount.set(4, 40);

    ScoreToPoints.set(250, 50);
    SeasonTime.set(1, 1740142800, 604800); //1740142800
    // SeasonTime.set(1, 1740060000, 604800); // week weeklyRecord
    CurrentSeasonDimension.set(0, 1); // current: week

    // comboReward startTime 
    SeasonTime.set(5, 1741269600, 86400);

    OverTime.set(0, 122);

    // over 5 star 
    StarToScore.set(0, 10);

    StarToScore.set(1, 15);
    StarToScore.set(2, 3);
    StarToScore.set(3, 9);
    StarToScore.set(4, 16);
    StarToScore.set(5, 25);
    // game success
    StarToScore.set(101, 150);

    // Additional rewards for logging in for 7 consecutive days
    DayToScore.set(0, 500);
    DayToScore.set(1, 20);
    DayToScore.set(2, 40);
    DayToScore.set(3, 60);
    DayToScore.set(4, 80);
    DayToScore.set(5, 100);
    DayToScore.set(6, 150);
    DayToScore.set(7, 200);
    // RankingRecord.set(0x60EA96f57B3a5715A90DAe1440a78f8bb339C92e, 9999999999, 0, 0, 0);

    // address[10] memory tokenAddress = [
    //   0xC750a84ECE60aFE3CBf4154958d18036D3f15786,
    //   0x65638Aa354d2dEC431aa851F52eC0528cc6D84f3,
    //   0xD64f7863d030Ae7090Fe0D8109E48B6f17f53145,
    //   0x160F5016Bb027695968df938aa04A95B575939f7,
    //   0x1ca53886132119F99eE4994cA9D0a9BcCD2bB96f,
    //   0x7Ea470137215BDD77370fC3b049bd1d009e409f9,
    //   0xca7f09561D1d80C5b31b390c8182A0554CF09F21,
    //   0xdCc7Bd0964B467554C9b64d3eD610Dff12AF794e,
    //   0x54b31D72a658A5145704E8fC2cAf5f87855cc1Cd,
    //   0xF66D7aB71764feae0e15E75BAB89Bd0081a7180d
    // ];
    // address[] memory dynamicTokenAddress = new address[](10);

    // for (uint256 i = 0; i < 10; i++) {
    //   dynamicTokenAddress[i] = tokenAddress[i];
    // }
    // Token.set(0, dynamicTokenAddress);

    address[10] memory tokenAddress = [
      0x0000000000000000000000000000000000000003,
      0x0000000000000000000000000000000000000004,
      0x0000000000000000000000000000000000000005,
      0x0000000000000000000000000000000000000006,
      0x0000000000000000000000000000000000000007,
      0x0000000000000000000000000000000000000008,
      0x0000000000000000000000000000000000000009,
      0x0000000000000000000000000000000000000010,
      0x0000000000000000000000000000000000000011,
      0x0000000000000000000000000000000000000012
    ];
    address[] memory dynamicTokenAddress = new address[](10);

    for (uint256 i = 0; i < tokenAddress.length; i++) {
      dynamicTokenAddress[i] = tokenAddress[i];
    }
    Token.set(0, dynamicTokenAddress);

    address[10] memory priTokenAddress = [
      0x0000000000000000000000000000000000000003,
      0x0000000000000000000000000000000000000004,
      0x0000000000000000000000000000000000000005,
      0x0000000000000000000000000000000000000006,
      0x0000000000000000000000000000000000000007,
      0x0000000000000000000000000000000000000008,
      0x0000000000000000000000000000000000000009,
      0x0000000000000000000000000000000000000010,
      0x0000000000000000000000000000000000000011,
      0x0000000000000000000000000000000000000012
    ];
    address[] memory priDynamicTokenAddress = new address[](10);
    for (uint256 i = 0; i < priTokenAddress.length; i++) {
      priDynamicTokenAddress[i] = priTokenAddress[i];
    }
    Token.set(1, priDynamicTokenAddress);

    PriTokenPrice.set(0x0000000000000000000000000000000000000003, 8000000000000);
    PriTokenPrice.set(0x0000000000000000000000000000000000000004, 8000000000000);
    PriTokenPrice.set(0x0000000000000000000000000000000000000005, 8000000000000);
    PriTokenPrice.set(0x0000000000000000000000000000000000000006, 8000000000000);
    PriTokenPrice.set(0x0000000000000000000000000000000000000007, 8000000000000);
    PriTokenPrice.set(0x0000000000000000000000000000000000000008, 8000000000000);
    PriTokenPrice.set(0x0000000000000000000000000000000000000009, 8000000000000);
    PriTokenPrice.set(0x0000000000000000000000000000000000000010, 8000000000000);
    PriTokenPrice.set(0x0000000000000000000000000000000000000011, 8000000000000);
    PriTokenPrice.set(0x0000000000000000000000000000000000000012, 8000000000000);

    PopCraftSystem popCraftSystem = new PopCraftSystem();
    console.log("SYSTEM_ADDRESS: ", address(popCraftSystem));
    
    world.registerSystem(systemResource, popCraftSystem, true);
    world.registerFunctionSelector(systemResource, "init()");
    // world.registerFunctionSelector(systemResource, "buyToken((bytes,uint256,(address,uint256))[])");

    // world.registerFunctionSelector(systemResource, "interact((address,string,(uint32,uint32),string))");
    // world.registerFunctionSelector(systemResource, "pop((address,string,(uint32,uint32),string))");
    // // world.registerFunctionSelector(systemResource, "withDrawToken(address,uint256)");
    // world.registerFunctionSelector(systemResource, "reIssuanceRewards(address[])");
    vm.stopBroadcast();
  }

}