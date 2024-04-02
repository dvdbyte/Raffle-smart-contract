// Layout of Contract:
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
pragma solidity 0.8.19;


/**
 * @title Smart Contract Raffle
 * @author dvdbyte
 * @notice This contract is creating a sample raffle
 * @dev Implementats Chainlink VRFv2
 */




contract Raffle {

  error Raffle__NotEnoughEthSent(); 

  uint256 private immutable  i_entranceFee; 
  // @dev duration of the lotttery in seconds
  uint256 private immutable i_interval;
  address payable[] private s_players;
  uint256 private s_lastTimeStamp;


  event enterdRaffle(address indexed player);

  constructor (uint256 entranceFee, uint256 interval) {
    i_entranceFee = entranceFee;
    i_interval = interval;
    s_lastTimeStamp = block.timestamp;
  }

  function enterRaffle() external payable {
    if (msg.value < i_entranceFee) {revert Raffle__NotEnoughEthSent();}
    s_players.push(payable(msg.sender));
    emit enterdRaffle(msg.sender);

  }



  //  1. Get a random number
  // 2. Use the random number to pick a player
  // 3. Be automatically called
  function pickWinner () external  {
    if(block.timestamp - s_lastTimeStamp) < i_interval {
      revert();
    };

    
  }


 /** Getter Functions */
 function getEntranceFee() external view returns (uint256) {
    return i_entranceFee;
 }
}


// 3. Using chainlink VRF & Chainlink Automation
//       1. Chainlink VRF -> Randomness
//       2. Chainlink Automaion -> Time based trigger


