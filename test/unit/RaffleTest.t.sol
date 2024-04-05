// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeloyRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";

contract RaffleTest is Test {
  Raffle raffle;

  address PLAYER = makeAddr("player");
  uint256 constant INITIAL_PLAYER_BALANCE = 10 ether;
  uint constant SEND_VALUE = 0.1 ether;

  function setUp () external {
    DeployRaffle deployRaffle = new DeployRaffle();
    raffle = deployRaffle.run();

  }


}