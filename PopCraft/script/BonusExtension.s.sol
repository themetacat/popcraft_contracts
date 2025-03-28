// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;
 
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IBaseWorld } from "@latticexyz/world-modules/src/interfaces/IBaseWorld.sol";
import { WorldRegistrationSystem } from "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { UserBenefitsToken, NFTRewards } from "../src/codegen/index.sol";
import { BonusSystem } from "../src/systems/BonusSystem.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

contract BonusExtension is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address worldAddress = vm.envAddress("WORLD_ADDRESS");
    console.log("world Address: ", worldAddress);
 
    WorldRegistrationSystem world = WorldRegistrationSystem(worldAddress);
    ResourceId namespaceResource = WorldResourceIdLib.encodeNamespace(bytes14("popCraft"));
    ResourceId systemResource = WorldResourceIdLib.encode(RESOURCE_SYSTEM, "popCraft", "BonusSystem");
    console.log("Namespace ID: %x", uint256(ResourceId.unwrap(namespaceResource)));
    console.log("System ID:    %x", uint256(ResourceId.unwrap(systemResource)));

    vm.startBroadcast(deployerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    UserBenefitsToken.register();
    NFTRewards.register();
    // 2 3 7 27 37 38 39 40  54
    NFTRewards.set(2, true, 0xb80AF1d22D36A9B03C7725bdd74cabAE8cbB220b);
    NFTRewards.set(3, true, 0x99FD88012229473B13011c821B24Ebf8AabF82c4);
    NFTRewards.set(7, true, 0x392796f95B2398Aa98D55e3dF5967D20F5A97F18);
    NFTRewards.set(27, true, 0xD3d0406AE6c6bE123bE80580cD9FbD4d96033DBB);
    NFTRewards.set(37, true, 0xD3d0406AE6c6bE123bE80580cD9FbD4d96033DBB);
    NFTRewards.set(38, true, 0xD3d0406AE6c6bE123bE80580cD9FbD4d96033DBB);
    NFTRewards.set(39, true, 0xD3d0406AE6c6bE123bE80580cD9FbD4d96033DBB);
    NFTRewards.set(40, true, 0xD3d0406AE6c6bE123bE80580cD9FbD4d96033DBB);
    NFTRewards.set(54, true, 0xDa68a8f7dAdaEd387be410BBD172E8Af4ee383A7);

    BonusSystem bonusSystem = new BonusSystem();
    console.log("SYSTEM_ADDRESS: ", address(bonusSystem));
    world.registerSystem(systemResource, bonusSystem, true);
   
    vm.stopBroadcast();
  }

}