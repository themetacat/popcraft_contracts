// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;
 
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IBaseWorld } from "@latticexyz/world-modules/src/interfaces/IBaseWorld.sol";
import { WorldRegistrationSystem } from "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { DailyGames, SeasonTime, GamesRewardsScores, StreakDays } from "../src/codegen/index.sol";
import { MissionSystem } from "../src/systems/MissionSystem.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

contract PlantsExtension is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address worldAddress = vm.envAddress("WORLD_ADDRESS");
    console.log("world Address: ", worldAddress);
 
    WorldRegistrationSystem world = WorldRegistrationSystem(worldAddress);
    ResourceId namespaceResource = WorldResourceIdLib.encodeNamespace(bytes14("popCraft"));
    ResourceId systemResource = WorldResourceIdLib.encode(RESOURCE_SYSTEM, "popCraft", "MissionSystem");
    console.log("Namespace ID: %x", uint256(ResourceId.unwrap(namespaceResource)));
    console.log("System ID:    %x", uint256(ResourceId.unwrap(systemResource)));

    vm.startBroadcast(deployerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);

    DailyGames.register();
    GamesRewardsScores.register();
    StreakDays.register();

    // in-day bonus
    SeasonTime.set(2, 1740747600, 86400); //1740747600
    // SeasonTime.set(2, 1740664800, 86400);

    // in-day bonus
    GamesRewardsScores.set(1, 3, 150);
    GamesRewardsScores.set(1, 5, 350);
    GamesRewardsScores.set(1, 10, 1000);
    GamesRewardsScores.set(1, 20, 3000);
    GamesRewardsScores.set(1, 50, 10000);

    // streak day
    SeasonTime.set(3, 1741352400, 604800); //1741352400
    // SeasonTime.set(3, 1741269600, 604800);

    // day
    SeasonTime.set(4, 0, 86400);

    // streak day
    GamesRewardsScores.set(2, 1, 50);
    GamesRewardsScores.set(2, 2, 150);
    GamesRewardsScores.set(2, 3, 300);
    GamesRewardsScores.set(2, 4, 500);
    GamesRewardsScores.set(2, 5, 750);
    GamesRewardsScores.set(2, 6, 1100);
    GamesRewardsScores.set(2, 7, 1500);

    // GamesRewardsScores.set(1, 1, 0);

    MissionSystem missionSystem = new MissionSystem();
    console.log("SYSTEM_ADDRESS: ", address(missionSystem));
    world.registerSystem(systemResource, missionSystem, true);
   
    vm.stopBroadcast();
  }

}