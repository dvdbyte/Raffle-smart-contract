//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test{
    /**Events */
    event EnteredRaffle (address indexed player);
    Raffle raffle;
    HelperConfig helperConfig;

    uint64 subscriptionId;
    bytes32 keyHash;
    uint256 timeInterval;
    uint256 entranceFee; 
    uint32 callbackGasLimit;
    address vrfCordinatorV2;
    address link;

    address public PLAYER = makeAddr("player");
    uint256 public constant INNITIAL_BALANCE = 10 ether;

    function setUp() external {
      DeployRaffle deployer = new DeployRaffle();
      (raffle, helperConfig) = deployer.run();
      (
        subscriptionId, 
        keyHash, 
        timeInterval, 
        entranceFee, 
        callbackGasLimit, 
        vrfCordinatorV2,
        link,
      ) = helperConfig.activeNetworkConfig();

    vm.deal(PLAYER, INNITIAL_BALANCE);
    }

    function testRaffleInitializesInOpenState() external view{
      assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    // Enter Raffle
    function testrRaffleFailsWithoutEnoughEth() public {
      vm.prank(PLAYER);
      vm.expectRevert(Raffle.Raffle__NotEnoughFeeToEnterRaffle.selector);
      raffle.enterRaffle();
    }
    function testRaffleRecordsPlayerWhenTheyEnter()public {
      vm.prank(PLAYER);
      vm.deal(PLAYER, INNITIAL_BALANCE);
      raffle.enterRaffle{value: entranceFee}();
      address playerRecorded = raffle.getPlayers(0);
      assert(playerRecorded == PLAYER);
    }

    function testEmitEventOnEntrance() public {
      vm.prank(PLAYER);
      vm.deal(PLAYER, INNITIAL_BALANCE);
      vm.expectEmit(true, false, false, false, address(raffle));
      emit EnteredRaffle(PLAYER);
      raffle.enterRaffle{value: entranceFee}();
    }

    function testCantEnterWhenRaffleIsCalculating() public raffleEnteredTimePassed {
      raffle.performUpkeep("");
      vm.expectRevert(Raffle.Raffle__CantEnterNow.selector);
      vm.prank(PLAYER);
      vm.deal(PLAYER, INNITIAL_BALANCE);
      raffle.enterRaffle{value:entranceFee}();
      
    }
  //////////////////////////////////////////////////////////////////////
  //////////////////   CHECK UPKEEP  ///////////////////////////////////
  //////////////////////////////////////////////////////////////////////
  function testCheckUpkeepReturnsFalseIfItHasNoBalance() public {
      // Arrange
      vm.warp(block.timestamp + timeInterval + 1);
      vm.roll(block.number + 1);

      // Act
      (bool upkeepneeded,) = raffle.checkUpkeep("");

      // Assert
      assert(!upkeepneeded);
    }

    function testCheckUpKeepReturnsFalseIfRaffleIsNotOpen () public raffleEnteredTimePassed {
      // Arrange
      raffle.getRaffleState() == Raffle.RaffleState.OPEN;
      raffle.performUpkeep("");

      // Act
      (bool upKeepNeeded,) = raffle.checkUpkeep("");
      // Assert
      // assert(raffleState == Raffle.RaffleState.CALCULATING);
      assert(upKeepNeeded == false );
    }

  ////////////////////////////////////////////////////////////////////////
  //////////////////   PERFORM UPKEEP  ///////////////////////////////////
  ////////////////////////////////////////////////////////////////////////

    function testPerformUpKeepCanOnlyRunIfCheckUpKeepIsTrue() public raffleEnteredTimePassed skipFork{
      // arrange
      raffle.performUpkeep("");

    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
      // Arrange 
      uint256 currentBalance = 0;
      uint256 numPlayers = 0;
      uint256 rState = 0;
      vm.expectRevert(
        abi.encodeWithSelector(
          Raffle.Raffle__UpkeepNotNeeded.selector,
          currentBalance, 
          numPlayers, 
          rState
          )
      );
      raffle.performUpkeep("");
    }




    
    modifier raffleEnteredTimePassed() {
      vm.prank(PLAYER);
      vm.deal(PLAYER, INNITIAL_BALANCE);
      raffle.enterRaffle{value: entranceFee}();
      vm.warp(block.timestamp + timeInterval + 1);
      vm.roll(block.number + 1);
      _;
    }
    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public raffleEnteredTimePassed{

      // Act
      vm.recordLogs();
      raffle.performUpkeep("");
      Vm.Log[]memory entries = vm.getRecordedLogs();
      bytes32 requestId = entries[1].topics[1];

      Raffle.RaffleState rState = raffle.getRaffleState();
      assert(uint256(requestId) > 0);
      assert(uint256(rState) == 1);
    }
  ////////////////////////////////////////////////////////////////////////
  //////////////////  FULFILL RANDOM WORDS  //////////////////////////////
  ////////////////////////////////////////////////////////////////////////

  modifier skipFork {
    if (block.chainid !=  31337) {
      return;
    }
    _;
  }
  function testFulfillrandomWordsCanOnlyBeCalledAffterPerformUpKeep(uint256 randomRequestId) public raffleEnteredTimePassed skipFork {
    vm.expectRevert("nonexistent request");
    VRFCoordinatorV2Mock(vrfCordinatorV2).fulfillRandomWords(randomRequestId, address(raffle));
  }

  function testFulfillRandomWordsPicksWinnerResetsAndSendMoney() public raffleEnteredTimePassed skipFork {
    // Arrange
    uint256 additionalEntrants = 5;
    uint256 startingIndex = 1;
    for (uint256 i = startingIndex; i < startingIndex + additionalEntrants; i++) 
    {
      address player = address (uint160(i));
      hoax(player, INNITIAL_BALANCE);
      raffle.enterRaffle{value: entranceFee}();
    }

    uint256 prize = entranceFee * (additionalEntrants + 1);
    vm.recordLogs();
    raffle.performUpkeep("");

    uint256 startingTimeStamp = raffle.getLastTimeStamp();

    Vm.Log[]memory entries = vm.getRecordedLogs();
    bytes32 requestId = entries[1].topics[1];

    uint256 endingTimeStamp = raffle.getLastTimeStamp();

    VRFCoordinatorV2Mock(vrfCordinatorV2).fulfillRandomWords(uint256(requestId), address(raffle));
  
    // Assert
    assert(uint256(raffle.getRaffleState()) == 0);
    assert(raffle.getRecentWinner() != address(0));
    assert(raffle.getLengthOfPlayers() == 0);
    // assert(endingTimeStamp < startingTimeStamp);
    assert(raffle.getRecentWinner().balance == INNITIAL_BALANCE + prize - entranceFee);


  }
}