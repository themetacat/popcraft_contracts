// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;
 
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IBaseWorld } from "@latticexyz/world-modules/src/interfaces/IBaseWorld.sol";
import { WorldRegistrationSystem } from "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { PlantsToGP, GPConsumeValue } from "../src/codegen/index.sol";
import { ExchangeSystem } from "../src/systems/ExchangeSystem.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

contract InviteExtension is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address worldAddress = vm.envAddress("WORLD_ADDRESS");
    console.log("world Address: ", worldAddress);
 
    WorldRegistrationSystem world = WorldRegistrationSystem(worldAddress);
    ResourceId namespaceResource = WorldResourceIdLib.encodeNamespace(bytes14("popCraft"));
    ResourceId systemResource = WorldResourceIdLib.encode(RESOURCE_SYSTEM, "popCraft", "ExchangeSystem");
    console.log("Namespace ID: %x", uint256(ResourceId.unwrap(namespaceResource)));
    console.log("System ID:    %x", uint256(ResourceId.unwrap(systemResource)));

    vm.startBroadcast(deployerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);

    PlantsToGP.register();
    GPConsumeValue.register();

    PlantsToGP.set(1, 3000);
    PlantsToGP.set(2, 1500);
    PlantsToGP.set(3, 1500);
    PlantsToGP.set(4, 4500);
    PlantsToGP.set(5, 4500);
    PlantsToGP.set(6, 3000);
    PlantsToGP.set(7, 1500);
    PlantsToGP.set(8, 3000);

    ExchangeSystem exchangeSystem = new ExchangeSystem();
    console.log("SYSTEM_ADDRESS: ", address(exchangeSystem));
    world.registerSystem(systemResource, exchangeSystem, true);

    vm.stopBroadcast();
  }

}
