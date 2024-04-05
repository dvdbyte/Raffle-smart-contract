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




contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughEth();
    error Raffle__NotEnoughTimeHasPassed();
    error Raffle__CantEnterAtTheMoment();

    uint256 immutable i_raffleFee;
    uint256 immutable i_timeInterval;
    uint256 private s_timeStamp;

   VRFCoordinatorV2Interface COORDINATOR;

  uint64 immutable i_subscriptionId;
  address immutable i_owner;
  address immutable i_vrfCoordinator;
  bytes32 immutable i_keyHash; 
  uint32 immutable i_callbackGasLimit;

  uint16 private constant REQUEST_CONFIRMATION = 3;
  uint32 private constant NUM_WORDS =  1;

  RaffleState initial = RaffleState.OPEN;


    address payable[] s_players;

    enum RaffleState {OPEN, RUNNING}

    event enteredRaffle(address indexed player);

    constructor 
    (
      uint64 subscriptionId,
      address vrfCoordinator,
      bytes32 keyHash,
      uint32 callbackGasLimit,

      uint256 raffleFee, 
      uint256 timeInterval) VRFConsumerBaseV2(vrfCoordinator)
    {

      i_subscriptionId = subscriptionId;
      i_owner = msg.sender;
      i_vrfCoordinator = vrfCoordinator;
      i_keyHash = keyHash;
      i_callbackGasLimit = callbackGasLimit;

      i_raffleFee = raffleFee;
      i_timeInterval = timeInterval;
      s_timeStamp = block.timeStamp;
    }
  
  function enterRaffle () external payable {
    if (msg.value < i_raffleFee) {
      revert Raffle__NotEnoughEth();
    }

    if (!initial) {
      revert Raffle__CantEnterAtTheMoment();
    }

    s_players.push(payable(msg.sender));
    emit enteredRaffle(msg.sender);
  }


  function pickWinner() external payable {
    if ((block.timestamp - s_timeStamp) < i_timeInterval){
        revert Raffle__NotEnoughTimeHasPassed();
    }
  uint256 requestId = COORDINATOR.requestRandomWords(
        i_keyHash,
        i_subscriptionId,
        REQUEST_CONFIRMATION,
        i_callbackGasLimit,
        NUM_WORDS
       );
  }
  
  function fulfillRandomWords
  (uint256 requestId, 
  uint256[] memory randomWords
  ) internal override {

       
  }



  //  1. Get a random number
  // 2. Use the random number to pick a player
  // 3. Be automatically called
  


 /** Getter Functions */
 
}


// 3. Using chainlink VRF & Chainlink Automation
//       1. Chainlink VRF -> Randomness
//       2. Chainlink Automaion -> Time based trigger


