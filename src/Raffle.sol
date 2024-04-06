/////////////////////////////////
///////Layout of Contract:///////
/////////////////////////////////
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions
// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions


// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Raffle {

    error Raffle__NotEnoughFeeToEnterRaffle();
    error Raffle__NotEnoughEthToPayWinner();
    error Raffle__NotEnoughTimeHasPassed();
    error Raffle__CantEnterNoow();

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_timeInterval;
    
    uint256 private s_timeStamp;

    address payable [] s_players;
    address payable [] recentWiner;

    RaffleState s_raffleState;
    /**Events */

    event enteredRaffle (address indexed player);
    enum  RaffleState{
        OPEN,
        CALCULATING
    }

    constructor(uint256 timeInterval) {
      i_entranceFee = 0.1 ether;
      s_timeStamp = block.timestamp;
      i_timeInterval = timeInterval;
      s_raffleState = RaffleState.OPEN;
    }
    
    function enterRaffle () external payable {
      if(msg.value < i_entranceFee) {
        revert Raffle__NotEnoughFeeToEnterRaffle();
      }

      if (s_raffleState != RaffleState.OPEN) {
        revert Raffle__CantEnterNoow();
      }
      s_players.push(payable(msg.sender));
      emit enteredRaffle(msg.sender);
    }

    function pickWinner() external {

      if ((block.timestamp - s_timeStamp) < i_timeInterval) {
          revert Raffle__NotEnoughTimeHasPassed();
      }

      s_raffleState == RaffleState.CALCULATING;


      // uint256 indexOfWinner = randomWord[0] % s_players.length;
      // address payable winner = s_players[indexOfWinner];
      // recentWiner.push(winner);
      // s_players = new address[](0);

    
      // (bool callSuccess,) = payable(winner).call{value: address(this).balance}("");
      // if (!callSuccess) {
      //  revert  Raffle__NotEnoughEthToPayWinner();
      // }

      s_raffleState = RaffleState.OPEN;
    }




  //  1. Get a random number
  // 2. Use the random number to pick a player
  // 3. Be automatically called
  


 /** Getter Functions */
 
}


// 3. Using chainlink VRF & Chainlink Automation
//       1. Chainlink VRF -> Randomness
//       2. Chainlink Automaion -> Time based trigger


