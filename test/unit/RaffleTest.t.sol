//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.sol";
import {Raffle} from "../../src/Raffle.sol";

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
      link
    ) = helperConfig.activeNetworkConfig();

   vm.deal(PLAYER, INNITIAL_BALANCE);
  }

  function testRaffleInitializesInOpenState() external{
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

  function testCantEnterWhenRaffleIsCalculating() public {
    vm.prank(PLAYER);
    vm.deal(PLAYER, INNITIAL_BALANCE);
    raffle.enterRaffle{value: entranceFee}();
    vm.warp(block.timestamp + timeInterval + 1);
    vm.roll(block.number + 1);
    raffle.performUpkeep("");
    vm.expectRevert(/*Raffle.Raffle__CantEnterNow.selector*/);
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

  function testCheckUpKeepReturnsFalseIfRaffleIsNotOpen () public {
    // Arrange
    raffle.getRaffleState() == Raffle.RaffleState.OPEN;
    vm.prank(PLAYER);
    // vm.deal(PLAYER, INNITIAL_BALANCE);
    raffle.enterRaffle{value: entranceFee}();
    vm.warp(block.timestamp + timeInterval + 1);
    vm.roll(block.number + 1);
    raffle.performUpkeep("");

    // Act
    (bool upKeepNeeded,) = raffle.checkUpkeep("");
    // Assert
    // assert(raffleState == Raffle.RaffleState.CALCULATING);
    assert(upKeepNeeded == false );
  }

//////////////////////////////////////////////////////////////////////
//////////////////   PERFORM UPKEEP  ///////////////////////////////////
//////////////////////////////////////////////////////////////////////

  function testPerformUpKeepCanOnlyRunIfCheckUpKeepIsTrue() public {
    // arrange
    vm.prank(PLAYER);
    raffle.enterRaffle{value: entranceFee}();
    vm.warp(block.timestamp + timeInterval + 1);
    vm.roll(block.number + 1);

    raffle.performUpkeep("");

  }

  function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
    // Arrange 
    uint256 currentBalance = 0;
    uint256 numPlayers = 0;
    uint256 raffleState = 0;
    vm.expectRevert(
      abi.encodeWithSelector(
        Raffle.Raffle__UpkeepNotNeeded.selector,
        currentBalance, 
        numPlayers, 
        raffleState
        )
    );
    raffle.performUpkeep("");
  }
}