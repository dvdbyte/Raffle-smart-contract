// SPDX-License-Identifier:MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";


////////////////////////////////////////////////////////////
//////////////////  CREATE SUBSCRIPTION  ///////////////////
////////////////////////////////////////////////////////////
contract CreateSubscription is Script{

function createSubscriptionUsingConfig() public returns (uint64){
    HelperConfig helperConfig = new HelperConfig();
    ( ,,,,,address vrfCoordinatorV2,) = helperConfig.activeNetworkConfig();
    }

function createSubscription(address vrfCoordinatorV2) public returns (uint64) {
  console.log("Creating subscription on chainId:", block.chainid);
  
  vm.startBroadcast();
  uint64 subId = VRFCoordinatorV2Mock(vrfCoordinatorV2).createSubscription();
  vm.stopBroadcast();
  
  console.log("Your sub Id is: ", subId);
  console.log("Please update subscriptionId in HelperConfig.s.sol");
  return subId;
}

    function run() external returns (uint64){
      return createSubscriptionUsingConfig();
    }
}

////////////////////////////////////////////////////////////
////////////////   FUND SUBSCRIPTION    ////////////////////
////////////////////////////////////////////////////////////
  contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
      HelperConfig helperConfig =new HelperConfig();
      (uint64 subscriptionId,,,,,address vrfCoordinatorV2, address link) = helperConfig.activeNetworkConfig();
      fundSubscription(vrfCoordinatorV2, subscriptionId, link);
    }

    function fundSubscription(address vrfCoordinatorV2, uint64 subscriptionId, address link) public {
        console.log("Funding Subscription", subscriptionId);
        console.log("Using vrfCordinatorV2", vrfCoordinatorV2);
        console.log("On chainId", block.chainid);

        if (block.chainid == 31337) {
          vm.startBroadcast();
          VRFCoordinatorV2Mock(vrfCoordinatorV2).fundSubscription(subscriptionId, FUND_AMOUNT);
          vm.stopBroadcast();
        }else {
          vm.startBroadcast();
          LinkToken(link).transferAndCall(vrfCoordinatorV2, FUND_AMOUNT, abi.encode(subscriptionId));
          vm.stopBroadcast();
        }
    }
    function run() external  {
      return fundSubscriptionUsingConfig();
    }
  }

////////////////////////////////////////////////////////////
///////////////////   ADD CONSUMMER  ///////////////////////
////////////////////////////////////////////////////////////
contract AddConsumer is Script {

     function addConsumer(address raffle, address vrfCoordinatorV2, uint64 subscriptionId) public {
        console.log("Adding Consumer Contract: ", raffle);
        console.log("Using vrfCoordinator: ", vrfCoordinatorV2);
        console.log("AOn ChainId: ", raffle);
        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinatorV2).addConsumer(subscriptionId, raffle);
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig (address raffle) public {
       HelperConfig helperConfig = new HelperConfig();
       (uint64 subscriptionId,,,,,address vrfCoordinatorV2,) = helperConfig.activeNetworkConfig();
       addConsumer(raffle, vrfCoordinatorV2, subscriptionId);
    }

    function run() external {
      address raffle = DevOpsTools.get_most_recent_deployment("raffle", block.chainid);
      addConsumerUsingConfig(raffle);
    }
  }
