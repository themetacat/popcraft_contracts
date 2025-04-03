// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { PlayerToInviteV2, InvitationScoreRecord, InvitationScoreRecordData, RankingRecord, WeeklyRecord, WeeklyRecord, InviteCodeToInviter } from "../codegen/index.sol";

library Invite {
  function addInviteScores(uint256 scores, address player, uint256 csd, uint256 currentSeason) internal {
    string memory code = PlayerToInviteV2.getCode(player);
    if(bytes(code).length == 0){
      return;
    }
    InvitationScoreRecordData memory invitationScoreRecordData = InvitationScoreRecord.get(player);
    uint256 lastestScores = invitationScoreRecordData.remainingScores + scores;
    
    uint256 addedScores = lastestScores / 10;
    address inviter = InviteCodeToInviter.get(keccak256(abi.encodePacked(code)));
    
    RankingRecord.setTotalScore(inviter, RankingRecord.getTotalScore(inviter) + addedScores);
    if(csd > 0 && currentSeason > 0){
        WeeklyRecord.setTotalScore(inviter, currentSeason, csd, WeeklyRecord.getTotalScore(inviter, currentSeason, csd) + addedScores);
    }
    InvitationScoreRecord.set(player, lastestScores % 10, invitationScoreRecordData.totalScores + scores);
  }

}
