// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;
 
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
// Create resource identifiers (for the namespace and system)
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { GameRecord, RankingRecord } from "../src/codegen/index.sol";
// forge script script/ClearRankRecord.s.sol --rpc-url http://127.0.0.1:8545 --broadcast

contract PopCraftExtension is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address worldAddress = vm.envAddress("WORLD_ADDRESS");
    console.log("world Address: ", worldAddress);
 
    vm.startBroadcast(deployerPrivateKey);
    StoreSwitch.setStoreAddress(worldAddress);
    // address[1] memory userAddress = [
    //   0x38BbD375d49d6237984cbfa19719c419af9FE514
    // ];
     address[9] memory userAddress = [
      0x450AF1Ea236932c0e18B53BC1FeB15E47AA292df,
      0xC5ab5dfcc104a9c81d678732241A00272D32eE6A,
      0x38BbD375d49d6237984cbfa19719c419af9FE514,
      0x47282Abf082321069536Fb84A78B217779ED53c6,
      0x9AabD861DFA0dcEf61b55864A03eF257F1c6093A,
      0x9a13C550cADb2ACF364e33eDc8E63a5d62f93260,
      0xE2C7E533375e032a97b3BDcd636a7a5174B17553,
      0x52Aa22a1baF886964F5756B9694F0BA67Ab7f839,
      0x9204ED743760BcAd81aB40B4442c8C81312d350a
    ];

    for (uint256 i = 0; i < 9; i++) {
      GameRecord.set(userAddress[i], 0, 0, 0);
      RankingRecord.set(userAddress[i], 0, 0, 0, 0);
      // GameRecord.deleteRecord(userAddress[i]);
      // RankingRecord.deleteRecord(userAddress[i]);
    }

    vm.stopBroadcast();
  }

}