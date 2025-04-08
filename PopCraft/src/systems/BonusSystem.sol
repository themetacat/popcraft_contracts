// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { UserBenefitsToken, Token, TokenBalance, TokenSold, TokenSoldData, NFTRewards, MorphBlack, MorphBlackRewards } from "../codegen/index.sol";
import { Check } from "../libraries/Check.sol";
import { Utils } from "../libraries/Utils.sol";
import { IERC721 } from "../interfaces/IERC721.sol";

contract BonusSystem is System {
  IERC721 private PopCraftGenesisNFT = IERC721(0xf6e9932469CBde5dB4b9293330Ff1897Bb43b2AE);

  function getUserBenefitsToken() public {
    address user = _msgSender();

    require(!UserBenefitsToken.get(user), "Already obtained");

    UserBenefitsToken.set(user, true);
    address[] memory priTokenAddr = Token.get(1);
    uint256 priTokenAddrLength = priTokenAddr.length;
    uint256 benefitsAmount = 2 * 10 ** 18;
    for (uint256 i; i < priTokenAddrLength; i++) {
      address tokenAddr = priTokenAddr[i];
      TokenBalance.set(user, tokenAddr, TokenBalance.get(user, tokenAddr) + benefitsAmount);

      TokenSoldData memory tokenSoldData = TokenSold.get(tokenAddr);
      TokenSold.set(tokenAddr, tokenSoldData.soldNow + benefitsAmount, tokenSoldData.soldAll + benefitsAmount);
    }
  }

  function getNFTRewardsToken() public {
    address player = _msgSender();
    uint256 NFTBalance = PopCraftGenesisNFT.balanceOf(player);
    require(NFTBalance > 0, "Balance: 0");

    uint256 rewardsNFT = 0;

    for (uint256 i; i < NFTBalance; i++) {
      uint256 tokenId = PopCraftGenesisNFT.tokenOfOwnerByIndex(player, i);
      if (!NFTRewards.getRecevied(tokenId)) {
        rewardsNFT += 1;
        NFTRewards.set(tokenId, true, player);
      }
    }
    require(rewardsNFT > 0, "Already obtained");
    uint256 rewardsAmount = rewardsNFT * 15 * 10 ** 18;
    address[] memory priToken = Token.get(1);
    for (uint256 i; i < priToken.length; i++) {
      address tokenAddress = priToken[i];
      TokenBalance.set(player, tokenAddress, TokenBalance.get(player, tokenAddress) + rewardsAmount);

      TokenSoldData memory tokenSoldData = TokenSold.get(tokenAddress);
      TokenSold.set(tokenAddress, tokenSoldData.soldNow + rewardsAmount, tokenSoldData.soldAll + rewardsAmount);
    }
  }

  function getMorphBlackRewardsToken() public {
    address player = _msgSender();
    uint256[] memory owned = MorphBlack.getOwned(player);
    require(owned.length > 0, "Balance: 0");

    uint256 rewardsNFT = 0;

    for (uint256 i; i < owned.length; i++) {
      uint256 tokenId = owned[i];
      if (!MorphBlackRewards.getRecevied(tokenId)) {
        rewardsNFT += 1;
        MorphBlackRewards.set(tokenId, true, player);
      }
    }
    require(rewardsNFT > 0, "Already obtained");
    uint256 rewardsAmount = rewardsNFT * 15 * 10 ** 18;
    address[] memory priToken = Token.get(1);
    for (uint256 i; i < priToken.length; i++) {
      address tokenAddress = priToken[i];
      TokenBalance.set(player, tokenAddress, TokenBalance.get(player, tokenAddress) + rewardsAmount);

      TokenSoldData memory tokenSoldData = TokenSold.get(tokenAddress);
      TokenSold.set(tokenAddress, tokenSoldData.soldNow + rewardsAmount, tokenSoldData.soldAll + rewardsAmount);
    }
  }

}
