var LotteryGame = artifacts.require("./LotteryGame.sol");

// Get contract accounts
contract('LotteryGame', function(accounts) {
  
  // First test
  it("should create a new Lottery correctly", function() {
    var meta;

    var account_owner = accounts[0];

    var maxTickets = 10;
    var ticketValue = web3.toWei(0.75,"ether");
    var prizePercentage = 80;

    var ticketPrice = 0;

    // Get contract instante
    return LotteryGame.deployed().then(function(instance) {
      meta = instance;
      // New game
      return meta.newLotteryGame(maxTickets, ticketValue, prizePercentage, {from: account_owner});
    }).then(function() {
      return meta.getTicketPrice.call();
    }).then(function(price) {
      ticketPrice = price.toNumber();
      // Test validation
      assert.equal(ticketValue, ticketPrice, "Ticket price isn't correct");
    });
  });

  // Second test
  it("should allow buy tickets", function() {
    var meta;

    var account_owner = accounts[0];
    var account_player1 = accounts[1];
    var account_player2 = accounts[2];
    var account_player3 = accounts[3];
    var account_player4 = accounts[4];

    var ticketPrice = 0;

    var ticketNumber1 = 0;
    var ticketNumber2 = 0;
    var ticketNumber3 = 0;
    var ticketNumber4 = 0;

     // Get contract instante
   return LotteryGame.deployed().then(function(instance) {
      meta = instance;
      return meta.getTicketPrice.call();
    }).then(function(price) {
      ticketPrice = price.toNumber();
      return meta.buyTicket({from: account_player1, value: ticketPrice});
    }).then(function(ticketNumber) {
      ticketNumber1 = ticketNumber;
      return meta.buyTicket({from: account_player2, value: ticketPrice});
    }).then(function(ticketNumber) {
      ticketNumber2 = ticketNumber;
      return meta.buyTicket({from: account_player3, value: ticketPrice});
    }).then(function(ticketNumber) {
      ticketNumber3 = ticketNumber;
      return meta.buyTicket({from: account_player4, value: ticketPrice});
    }).then(function(ticketNumber) {
      ticketNumber4 = ticketNumber;

      // Test validation
      assert(ticketNumber1 != 0, "Player 1 can't buy a ticket");
      assert(ticketNumber2 != 0, "Player 2 can't buy a ticket");
      assert(ticketNumber3 != 0, "Player 3 can't buy a ticket");
      assert(ticketNumber4 != 0, "Player 4 can't buy a ticket");
    });
  });

 // 3rd test
 it("should allow run a draw", function() {
    var meta;

    var account_owner = accounts[0];
    var account_player1 = accounts[1];
    var account_player2 = accounts[2];
    var account_player3 = accounts[3];
    var account_player4 = accounts[4];

    var ticketPrice = 0;
    var lotteryPrize = 0;
    var ticketWinner = 0;

    var account_player1_starting_balance = 0;
    var account_player2_starting_balance = 0;
    var account_player3_starting_balance = 0;
    var account_player4_starting_balance = 0;

    var account_player1_ending_balance = 0;
    var account_player2_ending_balance = 0;
    var account_player3_ending_balance = 0;
    var account_player4_ending_balance = 0;

    var winner = 0;

     // Get contract instante
   return LotteryGame.deployed().then(function(instance) {
      meta = instance;
      return web3.eth.getBalance(account_player1);
    }).then(function(balance) {
      account_player1_starting_balance = balance.toNumber();
      return web3.eth.getBalance(account_player2);
    }).then(function(balance) {
      account_player2_starting_balance = balance.toNumber();
      return web3.eth.getBalance(account_player3);
    }).then(function(balance) {
      account_player3_starting_balance = balance.toNumber();
      return web3.eth.getBalance(account_player4);
    }).then(function(balance) {
      account_player4_starting_balance = balance.toNumber();
      return meta.getLotteryPrize.call();
    }).then(function(prize) {
      lotteryPrize = prize.toNumber();
      return meta.getTicketPrice.call();
    }).then(function(price) {
      ticketPrice = price.toNumber();
      return meta.runTheDraw({from: account_owner});
    }).then(function(ticketNumber) {
      ticketWinner = ticketNumber;
      return web3.eth.getBalance(account_player1);
    }).then(function(balance) {
      account_player1_ending_balance = balance.toNumber();
      if (account_player1_ending_balance > account_player1_starting_balance) {
        winner = 1;
      }
      return web3.eth.getBalance(account_player2);
    }).then(function(balance) {
      account_player2_ending_balance = balance.toNumber();
      if (account_player2_ending_balance > account_player2_starting_balance) {
        winner = 2;
      }
      return web3.eth.getBalance(account_player3);
    }).then(function(balance) {
      account_player3_ending_balance = balance.toNumber();
      if (account_player3_ending_balance > account_player3_starting_balance) {
        winner = 3;
      }
      return web3.eth.getBalance(account_player4);
    }).then(function(balance) {
      account_player4_ending_balance = balance.toNumber();
      if (account_player4_ending_balance > account_player4_starting_balance) {
        winner = 4;
      }
      // Test validation
      assert(lotteryPrize > 0, "There is no prize");
      assert(winner > 0, "There is no Winner");
    });
  });
});
