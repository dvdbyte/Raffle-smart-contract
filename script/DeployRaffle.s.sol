// SPDX-License-Identifier
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract DeployRaffle is Script {

    function run() external returns (Raffle, Helperconfig) {

      vm.startBroadcast();

      Raffle raffle = new Raffle(
        


      )
      vm.stopBroadcast();    }

}