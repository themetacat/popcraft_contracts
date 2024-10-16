// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { FieldLayout, FieldLayoutLib } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { RESOURCE_TABLE, RESOURCE_OFFCHAIN_TABLE } from "@latticexyz/store/src/storeResourceTypes.sol";

ResourceId constant _tableId = ResourceId.wrap(
  bytes32(abi.encodePacked(RESOURCE_TABLE, bytes14("popCraft"), bytes16("RankingRecord")))
);
ResourceId constant RankingRecordTableId = _tableId;

FieldLayout constant _fieldLayout = FieldLayout.wrap(
  0x0080040020202020000000000000000000000000000000000000000000000000
);

struct RankingRecordData {
  uint256 totalScore;
  uint256 highestScore;
  uint256 latestScores;
  uint256 shortestTime;
}

library RankingRecord {
  /**
   * @notice Get the table values' field layout.
   * @return _fieldLayout The field layout for the table.
   */
  function getFieldLayout() internal pure returns (FieldLayout) {
    return _fieldLayout;
  }

  /**
   * @notice Get the table's key schema.
   * @return _keySchema The key schema for the table.
   */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _keySchema = new SchemaType[](1);
    _keySchema[0] = SchemaType.ADDRESS;

    return SchemaLib.encode(_keySchema);
  }

  /**
   * @notice Get the table's value schema.
   * @return _valueSchema The value schema for the table.
   */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _valueSchema = new SchemaType[](4);
    _valueSchema[0] = SchemaType.UINT256;
    _valueSchema[1] = SchemaType.UINT256;
    _valueSchema[2] = SchemaType.UINT256;
    _valueSchema[3] = SchemaType.UINT256;

    return SchemaLib.encode(_valueSchema);
  }

  /**
   * @notice Get the table's key field names.
   * @return keyNames An array of strings with the names of key fields.
   */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "owner";
  }

  /**
   * @notice Get the table's value field names.
   * @return fieldNames An array of strings with the names of value fields.
   */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](4);
    fieldNames[0] = "totalScore";
    fieldNames[1] = "highestScore";
    fieldNames[2] = "latestScores";
    fieldNames[3] = "shortestTime";
  }

  /**
   * @notice Register the table with its config.
   */
  function register() internal {
    StoreSwitch.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /**
   * @notice Register the table with its config.
   */
  function _register() internal {
    StoreCore.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /**
   * @notice Get totalScore.
   */
  function getTotalScore(address owner) internal view returns (uint256 totalScore) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get totalScore.
   */
  function _getTotalScore(address owner) internal view returns (uint256 totalScore) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set totalScore.
   */
  function setTotalScore(address owner, uint256 totalScore) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((totalScore)), _fieldLayout);
  }

  /**
   * @notice Set totalScore.
   */
  function _setTotalScore(address owner, uint256 totalScore) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((totalScore)), _fieldLayout);
  }

  /**
   * @notice Get highestScore.
   */
  function getHighestScore(address owner) internal view returns (uint256 highestScore) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get highestScore.
   */
  function _getHighestScore(address owner) internal view returns (uint256 highestScore) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set highestScore.
   */
  function setHighestScore(address owner, uint256 highestScore) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((highestScore)), _fieldLayout);
  }

  /**
   * @notice Set highestScore.
   */
  function _setHighestScore(address owner, uint256 highestScore) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((highestScore)), _fieldLayout);
  }

  /**
   * @notice Get latestScores.
   */
  function getLatestScores(address owner) internal view returns (uint256 latestScores) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get latestScores.
   */
  function _getLatestScores(address owner) internal view returns (uint256 latestScores) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set latestScores.
   */
  function setLatestScores(address owner, uint256 latestScores) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((latestScores)), _fieldLayout);
  }

  /**
   * @notice Set latestScores.
   */
  function _setLatestScores(address owner, uint256 latestScores) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((latestScores)), _fieldLayout);
  }

  /**
   * @notice Get shortestTime.
   */
  function getShortestTime(address owner) internal view returns (uint256 shortestTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get shortestTime.
   */
  function _getShortestTime(address owner) internal view returns (uint256 shortestTime) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set shortestTime.
   */
  function setShortestTime(address owner, uint256 shortestTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((shortestTime)), _fieldLayout);
  }

  /**
   * @notice Set shortestTime.
   */
  function _setShortestTime(address owner, uint256 shortestTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((shortestTime)), _fieldLayout);
  }

  /**
   * @notice Get the full data.
   */
  function get(address owner) internal view returns (RankingRecordData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    (bytes memory _staticData, PackedCounter _encodedLengths, bytes memory _dynamicData) = StoreSwitch.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data.
   */
  function _get(address owner) internal view returns (RankingRecordData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    (bytes memory _staticData, PackedCounter _encodedLengths, bytes memory _dynamicData) = StoreCore.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function set(
    address owner,
    uint256 totalScore,
    uint256 highestScore,
    uint256 latestScores,
    uint256 shortestTime
  ) internal {
    bytes memory _staticData = encodeStatic(totalScore, highestScore, latestScores, shortestTime);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    address owner,
    uint256 totalScore,
    uint256 highestScore,
    uint256 latestScores,
    uint256 shortestTime
  ) internal {
    bytes memory _staticData = encodeStatic(totalScore, highestScore, latestScores, shortestTime);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(address owner, RankingRecordData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.totalScore,
      _table.highestScore,
      _table.latestScores,
      _table.shortestTime
    );

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(address owner, RankingRecordData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.totalScore,
      _table.highestScore,
      _table.latestScores,
      _table.shortestTime
    );

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of static data using this table's field layout.
   */
  function decodeStatic(
    bytes memory _blob
  ) internal pure returns (uint256 totalScore, uint256 highestScore, uint256 latestScores, uint256 shortestTime) {
    totalScore = (uint256(Bytes.slice32(_blob, 0)));

    highestScore = (uint256(Bytes.slice32(_blob, 32)));

    latestScores = (uint256(Bytes.slice32(_blob, 64)));

    shortestTime = (uint256(Bytes.slice32(_blob, 96)));
  }

  /**
   * @notice Decode the tightly packed blobs using this table's field layout.
   * @param _staticData Tightly packed static fields.
   *
   *
   */
  function decode(
    bytes memory _staticData,
    PackedCounter,
    bytes memory
  ) internal pure returns (RankingRecordData memory _table) {
    (_table.totalScore, _table.highestScore, _table.latestScores, _table.shortestTime) = decodeStatic(_staticData);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function deleteRecord(address owner) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /**
   * @notice Delete all data for given keys.
   */
  function _deleteRecord(address owner) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
  }

  /**
   * @notice Tightly pack static (fixed length) data using this table's schema.
   * @return The static data, encoded into a sequence of bytes.
   */
  function encodeStatic(
    uint256 totalScore,
    uint256 highestScore,
    uint256 latestScores,
    uint256 shortestTime
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(totalScore, highestScore, latestScores, shortestTime);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dyanmic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    uint256 totalScore,
    uint256 highestScore,
    uint256 latestScores,
    uint256 shortestTime
  ) internal pure returns (bytes memory, PackedCounter, bytes memory) {
    bytes memory _staticData = encodeStatic(totalScore, highestScore, latestScores, shortestTime);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    return (_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Encode keys as a bytes32 array using this table's field layout.
   */
  function encodeKeyTuple(address owner) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = bytes32(uint256(uint160(owner)));

    return _keyTuple;
  }
}
