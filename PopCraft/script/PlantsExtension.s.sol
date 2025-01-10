// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;
 
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IBaseWorld } from "@latticexyz/world-modules/src/interfaces/IBaseWorld.sol";
import { WorldRegistrationSystem } from "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { Plants, TotalPlants, PlantsLevel, PlayerPlantingRecord, CurrentPlayerPlants } from "../src/codegen/index.sol";
import { PlantsSystem } from "../src/systems/PlantsSystem.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

contract PlantsExtension is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address worldAddress = vm.envAddress("WORLD_ADDRESS");
    console.log("world Address: ", worldAddress);
 
    WorldRegistrationSystem world = WorldRegistrationSystem(worldAddress);
    ResourceId namespaceResource = WorldResourceIdLib.encodeNamespace(bytes14("popCraft"));
    ResourceId systemResource = WorldResourceIdLib.encode(RESOURCE_SYSTEM, "popCraft", "PlantsSystem");
    console.log("Namespace ID: %x", uint256(ResourceId.unwrap(namespaceResource)));
    console.log("System ID:    %x", uint256(ResourceId.unwrap(systemResource)));

    vm.startBroadcast(deployerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);

    Plants.register();
    TotalPlants.register();
    PlantsLevel.register();
    PlayerPlantingRecord.register();
    CurrentPlayerPlants.register();
    
    Plants.set(1, 5, "Rose");
    Plants.set(2, 5, "Lotus");
    Plants.set(3, 5, "Tulip");
    Plants.set(4, 5, "Edelweiss");
    Plants.set(5, 5, "Plum blossom");
    Plants.set(6, 5, "Marigold");
    Plants.set(7, 5, "Chrysanthemum");
    Plants.set(8, 5, "Hydrangea");

    TotalPlants.set(0, 8);

    PlantsLevel.set(1, 1, 1000, 0, ""); // seed
    PlantsLevel.set(1, 2, 2000, 180, ""); // germinate 60s
    PlantsLevel.set(1, 3, 6000, 10800, ""); // stem leaf 3600s
    PlantsLevel.set(1, 4, 9000, 43200, ""); // flower bud 12h
    PlantsLevel.set(1, 5, 12000, 86400, ""); // bloom 24

    PlantsLevel.set(2, 1, 1000, 0, "");
    PlantsLevel.set(2, 2, 2000, 180, "");
    PlantsLevel.set(2, 3, 6000, 10800, "");
    PlantsLevel.set(2, 4, 9000, 43200, "");
    PlantsLevel.set(2, 5, 12000, 86400, "");

    PlantsLevel.set(3, 1, 1000, 0, "");
    PlantsLevel.set(3, 2, 2000, 180, "");
    PlantsLevel.set(3, 3, 6000, 10800, "");
    PlantsLevel.set(3, 4, 9000, 43200, "");
    PlantsLevel.set(3, 5, 12000, 86400, "");

    PlantsLevel.set(4, 1, 1000, 0, "");
    PlantsLevel.set(4, 2, 2000, 180, "");
    PlantsLevel.set(4, 3, 6000, 10800, "");
    PlantsLevel.set(4, 4, 9000, 43200, "");
    PlantsLevel.set(4, 5, 12000, 86400, "");

    PlantsLevel.set(5, 1, 1000, 0, "");
    PlantsLevel.set(5, 2, 2000, 180, "");
    PlantsLevel.set(5, 3, 6000, 10800, "");
    PlantsLevel.set(5, 4, 9000, 43200, "");
    PlantsLevel.set(5, 5, 12000, 86400, "");

    PlantsLevel.set(6, 1, 1000, 0, "");
    PlantsLevel.set(6, 2, 2000, 180, "");
    PlantsLevel.set(6, 3, 6000, 10800, "");
    PlantsLevel.set(6, 4, 9000, 43200, "");
    PlantsLevel.set(6, 5, 12000, 86400, "");

    PlantsLevel.set(7, 1, 1000, 0, "");
    PlantsLevel.set(7, 2, 2000, 180, "");
    PlantsLevel.set(7, 3, 6000, 10800, "");
    PlantsLevel.set(7, 4, 9000, 43200, "");
    PlantsLevel.set(7, 5, 12000, 86400, "");

    PlantsLevel.set(8, 1, 1000, 0, "");
    PlantsLevel.set(8, 2, 2000, 180, "");
    PlantsLevel.set(8, 3, 6000, 10800, "");
    PlantsLevel.set(8, 4, 9000, 43200, "");
    PlantsLevel.set(8, 5, 12000, 86400, "");

    PlantsSystem plantsSystem = new PlantsSystem();
    console.log("SYSTEM_ADDRESS: ", address(plantsSystem));
    world.registerSystem(systemResource, plantsSystem, true);
   
    vm.stopBroadcast();
  }

}