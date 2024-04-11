/** /////////////////////////////////
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

////
/** */
//SPDX License-Identifier: MIT
pragma solidity 0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {AutomationCompatible} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract Raffle is VRFConsumerBaseV2, AutomationCompatible{

    error Raffle__NotEnoughFeeToEnterRaffle();
    error Raffle__TransferFailed();
    error Raffle__NotEnoughTimeHasPassed();
    error Raffle__CantEnterNow();
    error Raffle__UpkeepNotNeeded( uint256 currentBalance, uint256 numPlayers, uint256 raffleState);

     /* State variables */
    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    address public immutable i_link;

    // Lottery Variables
    uint256 private immutable i_timeInterval;
    uint256 private immutable i_entranceFee;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    address payable [] private s_players;
    RaffleState private s_raffleState;

    /**Events */

    event EnteredRaffle (address indexed player);
    event WinnerPicked (address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    


    enum  RaffleState{
        OPEN,
        CALCULATING
    }

    constructor(uint64 subscriptionId, bytes32 keyHash, uint256 timeInterval, uint256 entranceFee, uint32 callbackGasLimit, address vrfCoordinatorV2, address link)  VRFConsumerBaseV2(vrfCoordinatorV2){
      i_subscriptionId = subscriptionId;
      i_keyHash = keyHash;
      i_timeInterval = timeInterval;
      i_entranceFee = entranceFee;
      i_callbackGasLimit = callbackGasLimit;
      i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
      i_link= link;

      s_lastTimeStamp = block.timestamp;
      s_raffleState = RaffleState.OPEN;
    }
    
    function enterRaffle () external payable {
      if(msg.value < i_entranceFee) {
        revert Raffle__NotEnoughFeeToEnterRaffle();
      }

      if (s_raffleState != RaffleState.OPEN) {
        revert Raffle__CantEnterNow();
      }
      s_players.push(payable(msg.sender));
      emit EnteredRaffle(msg.sender);
    }


    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
      bool timeHasPassed = (block.timestamp - s_lastTimeStamp) > i_timeInterval;
      bool isOpen = s_raffleState == RaffleState.OPEN;
      bool hasBalance = address(this).balance  > 0;
      bool hasPlayer = s_players.length > 0;
      upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayer);
      //  return (upkeepNeeded , "0x0");
    }
    function performUpkeep(bytes calldata /* performData */) public override  {
        (bool upkeepNeeded, ) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
      
      s_raffleState = RaffleState.CALCULATING;
      uint256 requestId = VRFCoordinatorV2Interface(i_vrfCoordinator).requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
      );
      emit RequestedRaffleWinner(requestId);
    }

     function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {

      uint256 indexOfWinner = _randomWords[0] % s_players.length;
      address payable winner = s_players[indexOfWinner];
      s_recentWinner = winner;
      s_players = new address payable [](0);

      s_raffleState = RaffleState.OPEN;

      emit WinnerPicked(winner);
      (bool success,) = payable(winner).call{value: address(this).balance}("");
      if (!success) {
       revert  Raffle__TransferFailed();
      }
   }
      


 /** Getter Functions */
 
  // uint64 private immutable i_subscriptionId;
  //   bytes32 private immutable i_keyHash;
  //   uint32 private immutable i_callbackGasLimit;
  //   uint256 private constant REQUEST_CONFIRMATIONS = 3;
  //   uint256 private constant NUM_WORDS = 1;


  //   uint256 private immutable i_timeInterval;
  //   uint256 private immutable i_entranceFee;
  //   uint256 private s_lastTimeStamp;
  function getLastTimeStamp() external view returns (uint256) {
    return s_lastTimeStamp;
  }
  function getRecentWinner() external view returns (address) {
    return s_recentWinner;
  }
  //   address payable [] private s_players;
  function getPlayers(uint256 indexOfPlayer) external view returns (address) {
    return s_players[indexOfPlayer];
  }


  //   RaffleState s_raffleState;
  function getEntranceFee() external view returns (uint256) {
    return i_entranceFee;
  }
  function getRaffleState() external view returns (RaffleState) {
    return s_raffleState;
  }

  function getLengthOfPlayers() external view returns (uint256) {
    return s_players.length;
  }


}