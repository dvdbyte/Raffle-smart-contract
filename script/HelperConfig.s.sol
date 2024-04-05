// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

 
contract HelperConfig {

  NetworkConfig activeNetworkConfig;

  struct NetworkConfig {
    uint64 subscriptionId;
    address  vrfCoordinator;
    bytes32  keyHash;
    uint32  callbackGasLimit;
    uint16  raffleFee;
    uint256 timeInterval;
  }

  constructor (activeNetworkConfig) {
    if (block.id == 11155111) {
      return getSepoliaEthConfig;
    }else {
      return getOrCreateAnvilConfig;
    }
  }



  function getSepoliaEthConfig() external returns (NetworkConfig memory) {
    return NetworkConfig({
        subscriptionId : id,
        vrfCoordinator : 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
        keyHash : 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
        callbackGasLimit :2500000,
        raffleFee : id,
        timeInterval: 30
    });
    }

    function getOrCreateAnvilConfig() external returns (NetworkConfig memory) {
      // Deploy Anvil chain
      vm.startBroadcast();
      VRFCoordinatorV2Mock vRFCoordinatorV2Mock = new VRFCoordinatorV2Mock();
      vm.StopBroadcast();

      return NetworkConfig({
        subscriptionId : id,
        vrfCoordinator : 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
        keyHash : 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
        callbackGasLimit :2500000,
        raffleFee : id,
        timeInterval: 30
        });
    }
}
