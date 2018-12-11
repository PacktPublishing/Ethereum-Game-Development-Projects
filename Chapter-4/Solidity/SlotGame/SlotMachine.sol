// Defines the compiler version
pragma solidity ^0.4.24;

import "./contracts/token/ERC20/SafeERC20.sol";
import "./contracts/ownership/Ownable.sol";
import "./contracts/token/ERC20/IERC20.sol";
import "./contracts/utils/ReentrancyGuard.sol";
import "./contracts/math/SafeMath.sol";

// The slot machine game contract
contract SlotMachine is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private casinoToken; // The casino token to sold

    uint constant reels = 3; // Total reels

    uint constant symbols = 20; // Total symbols

    uint constant maxPrize = 10; // Maximum prize

    address[symbols] randomPlayers; // Stores 20 recent players for random number generation
    uint[3 * symbols] randomSpins; // Stores 20 recent players for random number generation

    uint index = 0; // randomPlayers pointer 
    uint indexSpin = 0; // randomPlayers pointer 

    // Slot after spin
    struct Slots {
        uint slot1;
        uint slot2;
        uint slot3;
    }

    // Store all players coins
    mapping (address => uint) coins; 
    // Store all players bets       
    mapping (address => uint) bets; 
    // Store all players last spins       
    mapping (address => Slots) spins; 
    // Store all players last prizes       
    mapping (address => uint) prizes; 
    
    enum GameStatus { Running, Stopped } // The status of the game
      
    GameStatus status; // The curretn game status
    
    // Event with the result: player, bet, prize, slot1, slot2, slot3
    event SpinResult(address indexed player, uint playerbet, uint playerprize, uint spinslot1, uint spinslot2, uint spinslot3);

    // At the deploy define Casino Token address
    constructor() public {
        status = GameStatus.Stopped; // After deploy game is inactive
    }
    
   // Do not acept Ether at this contract address
    function () public payable {
        revert();
    }

    // Set the token address
    function setToken(address _casinoToken) public onlyOwner {
        require(_casinoToken != address(0));
        casinoToken = IERC20(_casinoToken);
        status = GameStatus.Running; // After set token address is active
    }

    // Extract coins from the slot machine
    function extractCoins(address _wallet, uint _value) public onlyOwner {
        require(_value <= casinoToken.balanceOf(this));
        require(_wallet != address(0));
       // Send coin tokens to the mahcine owner
        casinoToken.safeTransfer(this, _value);
    }

    // To enter casino tokens player must first to call CasinoToken.approve(this, amount) to allow machine to get the tokens
    // this contract will not be able to do the transfer on user's behalf.
    function depositCoins(uint _tokenAmount) public nonReentrant {
        require(status == GameStatus.Running, "Machine is not running"); // Game must be selling
        require(_tokenAmount > 0, "Value can not be zero"); // You must enter a valid token amount
        require(casinoToken.allowance(msg.sender, this) >= _tokenAmount, "Use CasinoToken.approve to allow this token transfer"); // User must allow this transfer first
 
        // Add the new player to the players list for random number generation
        addPlayer(msg.sender); 

        // Get tokens from the player
        casinoToken.safeTransferFrom(msg.sender, this, _tokenAmount);

        // Add token values as coins to the machine
        coins[msg.sender] = coins[msg.sender].add(_tokenAmount);
    }

    // Get how many coins player have
    function getCoins() public view returns (uint) {
        return coins[msg.sender];
    }
 
    // Set player bet in coins
    function setBet(uint _bet) public {
        require(coins[msg.sender] >= _bet, "Out of coins for this bet");
        require(casinoToken.balanceOf(this) > _bet.mul(maxPrize), "Machine out of tokens to pay for this bet");

        // Set bet value to the player
        bets[msg.sender] = _bet;
    }

    // Get current player bet
    function getBet() public view returns (uint) {
        return bets[msg.sender];
    }

    // Spin the slots
    function runSpin() public nonReentrant {
        require(coins[msg.sender] >= bets[msg.sender], "Out of coins for this spin");

        // Get the player bet from the available coins
        coins[msg.sender] = coins[msg.sender].sub(bets[msg.sender]);

        // Get the symbol in each slot
        spins[msg.sender] = getSpinResult();

        // Add the new spins to the players list for random number generation
        addSpins(spins[msg.sender].slot1, spins[msg.sender].slot2, spins[msg.sender].slot3); 

        // Check the result based on the paytable
        uint paytableIndex = getPayTableResult(spins[msg.sender]);
 
        // Check the prize
        prizes[msg.sender] = payPrize(msg.sender, paytableIndex);
        
        emit SpinResult(msg.sender, bets[msg.sender], prizes[msg.sender], spins[msg.sender].slot1, spins[msg.sender].slot2, spins[msg.sender].slot3);
    }

    // Get last player spin slot 1
    function lastSpinSlot1() public view returns (uint) {
        return spins[msg.sender].slot1;
    }

    // Get last player spin slot 2
    function lastSpinSlot2() public view returns (uint) {
        return spins[msg.sender].slot2;
    }

    // Get last player spin slot 3
    function lastSpinSlot3() public view returns (uint) {
        return spins[msg.sender].slot3;
    }

    // Get last player prize
    function lastPrize() public view returns (uint) {
        return prizes[msg.sender];
    }

    // Creates a list with the last 20 players for random number generation
    function addPlayer(address _newAddress) internal {
        randomPlayers[index] = _newAddress;
        index++;
        if (index >= randomPlayers.length) {
            index = 0;
        }
    }

        // Creates a list with the last 20 players for random number generation
    function addSpins(uint _newSpin1, uint _newSpin2, uint _newSpin3) internal {
        randomSpins[indexSpin] = _newSpin1;
        randomSpins[indexSpin+1] = _newSpin2;
        randomSpins[indexSpin+2] = _newSpin3;
        indexSpin+=3;
        if (index >= randomSpins.length) {
            index = 0;
        }
    }

    // Imprement the prize logic
    function calculatePrize(uint _bet, uint _index) internal pure returns (uint) {
        require(_index <= (maxPrize * 4), "Error while trying to calculate prize"); // The maximum index is maxPrize = maxIndex/4.

        // index zero means no prize
       if (_index == 0) {
         return 0;
       }
       // The index step is 25%, so bellow 4 player got less than bet.
       return (_index.mul(_bet).div(4));
    }

    // Pay the prize to the player
    function payPrize(address _player, uint _index) internal returns (uint) {

        // Calculate the prize based on player bet
        uint prize = calculatePrize(bets[_player], _index);

        // Send prize in tokens to the player
        if (prize > 0) {               
            casinoToken.safeTransfer(_player, prize);
        }

        return prize;
    }

    // Check payline 
    function getPayTableResult(Slots _slots) internal pure returns (uint) {
         // Sequence descending
        if (isSequenceDown(_slots.slot1, _slots.slot2, _slots.slot3)) {
            return 1; 
         // Sequence ascending
        } else if (isSequenceUp(_slots.slot1, _slots.slot2, _slots.slot3)) {
            return 3;
         // Diagonal down-up 
        } else if (isDown(_slots.slot1, _slots.slot2) && isUp(_slots.slot3, _slots.slot2)) {
            return 6;
         // Diagonal up-down 
        } else if (isUp(_slots.slot1, _slots.slot2) && isDown(_slots.slot3, _slots.slot2)) {
            return 8;
        // Horizontal line 
       } else if (isInline(_slots.slot1, _slots.slot2) && isInline(_slots.slot3, _slots.slot2)) {
            return 10;
        } 
        return 0;
    }

    // Slot machine rules
    function isInline(uint _slotA, uint _slotB) internal pure returns (bool) {
        return (_slotA == _slotB);
    }

    function isUp(uint _slotA, uint _slotB) internal pure returns (bool) {
        uint slotAup = _slotA;
        if (slotAup == (symbols - 1)) {
            slotAup = 0;
        } else {
             slotAup++;           
        }
        return (slotAup == _slotB);
    }

    function isDown(uint _slotA, uint _slotB) internal pure returns (bool) {
        uint slotAdown = _slotA;
        if (slotAdown == 0) {
            slotAdown = (symbols - 1);
        } else {
            slotAdown--;
        }

        return (slotAdown == _slotB);
    }

    function isSequenceUp(uint _slotA, uint _slotB, uint _slotC) internal pure returns (bool) {
        return (isUp(_slotA, _slotB) && isUp(_slotB, _slotC));
    }

    function isSequenceDown(uint _slotA, uint _slotB, uint _slotC) internal pure returns (bool) {
        return (isDown(_slotA, _slotB) && isDown(_slotB, _slotC));
    }    

    // Get the symbol in each slot
    function getSpinResult() internal view returns (Slots) {
      // There are many diferent solution to implement a random number
      // here we get the hash of concatenated bytes with current dificult, block time stamp, and the players address
      uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.difficulty, now, randomPlayers, randomSpins)));

      uint slot1 = randomNumber % symbols;
      uint slot1b = randomNumber / symbols;
      uint slot2 = slot1b % symbols;
      uint slot2b = slot1b / symbols;
      uint slot3 = slot2b % symbols;

      return Slots(slot1, slot2, slot3); 
    }
    
}
