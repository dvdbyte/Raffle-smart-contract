// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./interactions.s.sol";

contract DeployRaffle is Script {

    function run() external returns (Raffle, HelperConfig) {

      HelperConfig helperConfig = new HelperConfig();
      ( 
      uint64 subscriptionId, 
      bytes32 keyHash, 
      uint256 timeInterval, 
      uint256 entranceFee, 
      uint32 callbackGasLimit, 
      address vrfCoordinatorV2,
      address link,
      uint256 deployerKey
      ) = helperConfig.activeNetworkConfig();

      if (subscriptionId == 0) {
        CreateSubscription createSubscription = new CreateSubscription();
        subscriptionId = createSubscription.createSubscription(vrfCoordinatorV2, deployerKey);

        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(vrfCoordinatorV2, subscriptionId, link, deployerKey);
      }
      vm.startBroadcast();

      Raffle raffle = new Raffle(
        subscriptionId,  
        keyHash,  
        timeInterval, 
        entranceFee, 
        callbackGasLimit,  
        vrfCoordinatorV2,
        link
      ); 

      vm.stopBroadcast();  

      AddConsumer addConsumer = new AddConsumer();
      addConsumer.addConsumer(address(raffle), vrfCoordinatorV2, subscriptionId, deployerKey);

      return (raffle, helperConfig);
  }
}