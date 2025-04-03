// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { InviterV2, InviteCodeToInviter, PlayerToInviteV2, TCMPopStar } from "../codegen/index.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";

contract InviteSystem is System {

  bytes private constant CHARSET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz";
  uint8 private constant CODE_LENGTH = 10;

  function genInviteCode() public {
    address inviter = _msgSender();
    require(bytes(InviterV2.getCode(inviter)).length == 0, "Not reproducible");

    bytes32 hash = keccak256(abi.encodePacked(inviter));
    bytes memory bytesCode = new bytes(CODE_LENGTH);
    for (uint8 i = 0; i < CODE_LENGTH; i++) {
        uint8 charIndex = uint8(hash[i]) % uint8(CHARSET.length);
        bytesCode[i] = CHARSET[charIndex];
    }
    string memory code = string(bytesCode);
    address codeInviter = InviteCodeToInviter.get(keccak256(abi.encodePacked(code)));
    require(codeInviter == address(0) || codeInviter == inviter, "Code has been used");

    InviterV2.set(inviter, 1, code, InviterV2.getPlayer(inviter));
    InviteCodeToInviter.set(keccak256(abi.encodePacked(code)), inviter);
  }

  function acceptInvitation(string memory code) public {
    address player = _msgSender();
    address inviter = InviteCodeToInviter.get(keccak256(abi.encodePacked(code)));
    require(inviter != address(0) && inviter != player, "Invalid code");
    require(bytes(PlayerToInviteV2.getCode(player)).length == 0, "Already invited");
    require(TCMPopStar.getMatrixArray(player).length == 0, "Not a new user");

    address[] memory invitees = InviterV2.getPlayer(inviter);
    address[] memory newInvitees = new address[](invitees.length + 1);
    for (uint256 index = 0; index < invitees.length; index++) {
      newInvitees[index] = invitees[index];
    }
    newInvitees[invitees.length] = player;
    InviterV2.set(inviter, 1, InviterV2.getCode(inviter), newInvitees);
    PlayerToInviteV2.set(player, 1, code);
  }
}
