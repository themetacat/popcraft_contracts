import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "popStar",
  enums:{
  },
  tables: {
    PopStar: {
      keySchema:{
        timestamp: "uint256",
        owner: "address",
        app: "bytes32",
      },
      valueSchema:{
        x: "uint32",
        y: "uint32",
        gameFinished: "bool",
        matrixArray: "uint256[]",
      }
    }
  },
  systems: {
    PopStarSystem: {
      name: "PopStarSystem",
      openAccess: false
    },
  }
});
