// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;
 
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IBaseWorld } from "@latticexyz/world-modules/src/interfaces/IBaseWorld.sol";
import { WorldRegistrationSystem } from "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
// import { GameMode, ModeRecord, ModeWeeklyRecord } from "../src/codegen/index.sol";
import { MClearBoardSystem } from "../src/systems/MClearBoardSystem.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

contract MClearBoradExtension is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address worldAddress = vm.envAddress("WORLD_ADDRESS");
    console.log("world Address: ", worldAddress);
 
    WorldRegistrationSystem world = WorldRegistrationSystem(worldAddress);
    ResourceId namespaceResource = WorldResourceIdLib.encodeNamespace(bytes14("popCraft"));
    ResourceId systemResource = WorldResourceIdLib.encode(RESOURCE_SYSTEM, "popCraft", "MClearSystem");
    console.log("Namespace ID: %x", uint256(ResourceId.unwrap(namespaceResource)));
    console.log("System ID:    %x", uint256(ResourceId.unwrap(systemResource)));

    vm.startBroadcast(deployerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);

    MClearBoardSystem mClearBoardSystem = new MClearBoardSystem();
    console.log("SYSTEM_ADDRESS: ", address(mClearBoardSystem));
    world.registerSystem(systemResource, mClearBoardSystem, true);

    vm.stopBroadcast();
  }

}
