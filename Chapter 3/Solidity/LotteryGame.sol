// Defines the compiler version
pragma solidity ^0.4.24;

import './library/Ownable.sol';

// Main Lottery game smart contract
contract LotteryGame is Ownable {

  address[] players; // Stores all the Lottery players

  uint128 public maxTickets; // Maximum amount of players at the Lottery
  uint256 public ticketValue; // Price of each ticket

  uint64 public lotteryDraw; // Count how many draws we did so far

  uint16 public prizePercentage; // percentage of the balance that goes for the prize

  // Stores the last draw stats
  uint256 public lastWinner;
  address public lastWinnerAddress;
  uint256 public lastWinnerPrize;

  // Stores the total Lottery stats
  uint256 public totalPrizesValue;
  uint64 public totalPrizes;

  enum GameStatus { Selling, Stopped } // The status of the game
      
  GameStatus status; // The curretn game status

// Contructor
constructor() public {
    status = GameStatus.Stopped; // After deploy game is inactive
    lotteryDraw = 0; // Initialise for the first draw
    prizePercentage = 95; // The defualt is 95% of the balance goes to the prize and 5% goes to the owner
}

// Setup a new Lottery
function newLotteryGame(uint128 _maxTickets, uint256 _ticketValue, uint16 _prizePercentage) public onlyOwner {
    require(status == GameStatus.Stopped, "Lottery still selling"); // Game must be over with a winner
    require(address(this).balance == 0, "Balance is not zeroed"); // To start a new lotery balance must be 0 to avoid overlap with an unfinished draw
    require(_maxTickets > 0, "Can no be zero");
    require(_ticketValue > 0, "Can no be zero");
    require(_prizePercentage > 0, "Can no be zero");
    require(_prizePercentage <= 100, "Can no be more than 100");

    setMaxTickets(_maxTickets);

    setTicketPrice(_ticketValue);

    setPrizePercentage(_prizePercentage);

    if (players.length > 0) {
      players = new address[](0); // Remove all previous players      
    }
    
    lotteryDraw++; // Increase the draw counter

    status = GameStatus.Selling; // Game starts

}

function buyTicket() public payable returns (uint256) {
    require(status == GameStatus.Selling, "Lottery is not selling"); // Game must be selling
    require(players.length <= maxTickets, "Lottery tickets are all sold"); // Can not sell more than max tickets
    require(msg.value >= ticketValue, "Value bellow tickets price"); // You must pay the ticket price to play. But avoid overpaying

    // Add the new player to the players list for draw
    players.push(msg.sender); 

    // Create the ticket number
    uint256 ticketNumber = (maxTickets * lotteryDraw) + (players.length - 1);

    // Return the ticket number
    return ticketNumber;
}


// Run the draw, send the prize and return the winner to the owner control
function runTheDraw() public onlyOwner returns (uint256) {
  require(status == GameStatus.Selling, "Lottery is not selling"); // Game must be selling
  require(players.length >= 2, "Not enough players"); // requires minimum 2 players
  require(address(this).balance > 0, "Balance is zero"); // requires have a minimum balance
  require(prizePercentage > 0, "Percentage is zero"); // requires have a minimum prize percentage

  status = GameStatus.Stopped; // Game have a winner

  // Get a random ticket number.
  uint256 winnerTicket = getWinnerTicketNumber();
  
  // Get the winner address
  address winnerAddress = players[winnerTicket];

  uint256 balance = address(this).balance;
    
  // Get the prize amount.
  uint256 prizeAmount = (balance * prizePercentage) / 100;
  
  // send the rest of the balance to the owner.
  uint256 onwerAmount = balance - prizeAmount;

  address owner = getOwner();

  // Update game stats
  lastWinner = (maxTickets * lotteryDraw) + winnerTicket;
  lastWinnerAddress = winnerAddress;
  lastWinnerPrize = prizeAmount;
  totalPrizesValue += prizeAmount;
  totalPrizes++;
  
  // We include the transfer here to avoid re-entrancy, this is the Checks-Effects-Interactions pattern  
  // Transfer to the winner address
  winnerAddress.transfer(prizeAmount);

  if (onwerAmount > 0) {
    owner.transfer(onwerAmount);
  }

  // Return the winner ticket number
  return lastWinner;
}

// set the maximum tickets in the Lottery.
function setMaxTickets(uint128 _maxTickets) public onlyOwner {
    require(_maxTickets > 0, "Can no be zero");
    maxTickets = _maxTickets;
}

// set the unitary ticket price.
function setTicketPrice(uint256 _ticketValue) public onlyOwner {
    require(_ticketValue > 0, "Can no be zero");
    ticketValue = _ticketValue;
}

// set the Lottery prize as a percentage of the total tickets sold.
function setPrizePercentage(uint16 _prizePercentage) public onlyOwner {
  require(_prizePercentage > 0, "Can no be zero");
  require(_prizePercentage <= 100, "Can no be more than 100");
  prizePercentage = _prizePercentage;
}

// returns the current Lottery prize.
function getTicketPrice() public view returns (uint256) {
    return ticketValue;
}

// returns the current Lottery prize.
function getLotteryPrize() public view returns (uint256) {
    return (address(this).balance * prizePercentage) / 100;
}

// Get a random winner ticket index
function getWinnerTicketNumber() internal view returns(uint256) {
  // There are many diferent solution to implement a random number
  // here we get the hash of concatenated bytes with current dificult, block time stamp, and the players address
  uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.difficulty, now, players)));

  // Return a value in the range of winner numbers
  return randomNumber % players.length;

}

}