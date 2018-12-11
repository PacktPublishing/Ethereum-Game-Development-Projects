var CasinoToken = artifacts.require("./CasinoToken.sol");
var CoinsSale = artifacts.require("./CoinsSale.sol");
var SlotMachine = artifacts.require("./SlotMachine.sol");

var tokenAddress;

// Get token contract
contract('CasinoToken', function(accounts) {
   // First test
  it("should send Tokens to another addressess", function() {
    var meta;

    var account_owner = accounts[0];
    var account_player1 = accounts[1];
    var account_player2 = accounts[2];

    var valueToSend = web3.toWei(100,"ether");

    // Get contract instante
    return CasinoToken.deployed().then(function(instance) {
      meta = instance;

      tokenAddress = instance;
      // New game
      return meta.transfer(account_player1, valueToSend);
    }).then(function() {
      return meta.transfer(account_player2, valueToSend);
    }).then(function() {
      return meta.balanceOf(account_player1);
    }).then(function(balance) {
      balance_player1 = balance.toNumber();
      // Test validation
      assert.equal(balance_player1, valueToSend, "Balance player 1 is incorrect"+balance_player1);
      return meta.balanceOf(account_player2);
    }).then(function(balance) {
      balance_player2 = balance.toNumber();
      // Test validation
      assert.equal(balance_player2, valueToSend, "Balance player 2 is incorrect"+balance_player2);
    });
  });

  // Second test
  it("should send Tokens on behalf of others", function() {
    var meta;

    var account_owner = accounts[0];
    var account_player1 = accounts[1];
    var account_player2 = accounts[2];
    var account_player3 = accounts[3];

    var valueToSend = web3.toWei(10,"ether");

    var account_player1_starting_balance = 0;
    var account_player2_starting_balance = 0;
    var account_player3_starting_balance = 0;

    var account_player1_ending_balance = 0;
    var account_player2_ending_balance = 0;
    var account_player3_ending_balance = 0;

    // Get contract instante
    return CasinoToken.deployed().then(function(instance) {
      meta = instance;

      return meta.balanceOf(account_player1);
    }).then(function(balance) {
      account_player1_starting_balance = balance.toNumber();
      return meta.balanceOf(account_player2);
    }).then(function(balance) {
      account_player2_starting_balance = balance.toNumber();
      return meta.balanceOf(account_player3);
    }).then(function(balance) {
      account_player3_starting_balance = balance.toNumber();

      assert.equal(account_player3_starting_balance, 0, "Balance player 3 is not zero");

      // Player 1 approve player 2
      return meta.approve(account_player2, valueToSend, {from: account_player1});
    }).then(function() {
      return meta.transferFrom(account_player1, account_player3, valueToSend, {from: account_player2});
    }).then(function() {
      return meta.balanceOf(account_player1);
    }).then(function(balance) {
      account_player1_ending_balance = balance.toNumber();
      // Test validation
      assert.equal(account_player1_starting_balance - account_player1_ending_balance, valueToSend, "Balance player 1 is incorrect"+balance_player1);
      return meta.balanceOf(account_player3);
    }).then(function(balance) {
      account_player3_ending_balance = balance.toNumber();
      // Test validation
      assert.equal(account_player3_ending_balance + account_player3_starting_balance, valueToSend, "Balance player 3 is incorrect"+balance_player1);
    });
  });


   // Buy coins test
  it("should buy Tokens", function() {
      var meta;

      var account_owner = accounts[0];
      var account_player1 = accounts[1];

      var cashierValue = web3.toWei(1000,"ether");

      var valueToBuy = web3.toWei(10,"ether");

      var account_owner_starting_balance = 0;
      var account_owner_ending_balance = 0;

      var account_player1_starting_balance = 0;
      var account_player1_ending_balance = 0;

    // Get contract instante
    return CoinsSale.deployed().then(function(instance) {

      meta = instance;

      // Check owner balance
      return web3.eth.getBalance(account_owner);
    }).then(function(balance) {
      account_owner_starting_balance = balance.toNumber();
      // Set the wallet address
      return meta.setWallet(account_owner);
    }).then(function() {
      // Set the token address
      return meta.setToken(tokenAddress.address);
    }).then(function() {
      // Send cash to the selling machine
      return tokenAddress.transfer(meta.address, cashierValue);
    }).then(function() {
      return tokenAddress.balanceOf(account_player1);
    }).then(function(balance) {
      account_player1_starting_balance = balance.toNumber();
      return meta.buyCasinoTokensFor(account_player1, {from: account_player1, value: valueToBuy});
    }).then(function() {
      return web3.eth.getBalance(account_owner);
    }).then(function(balance) {
      account_owner_ending_balance = balance.toNumber();
      return tokenAddress.balanceOf(account_player1);
    }).then(function(balance) {
      account_player1_ending_balance = balance.toNumber();
      // Test validation
      assert(account_player1_ending_balance > account_player1_starting_balance, "Token Balance of player 1 was not reduced"+balance_player1);
      assert(account_owner_ending_balance > account_owner_starting_balance, "Ether balance of onwer was not increased"+balance_player1);
     });
    });

  // Set and run slot machine
  it("should spin slots", function() {
      var meta;

      var account_owner = accounts[0];
      var account_player1 = accounts[1];

      var coinsToAdd = web3.toWei(10,"ether");
      var valueToBet = web3.toWei(0.1,"ether");

      var account_player1_starting_balance = 0;
      var account_player1_ending_balance = 0;

    // Get contract instante
    return SlotMachine.deployed().then(function(instance) {

      meta = instance;

      // Set the token address
      return meta.setToken(tokenAddress.address);
    }).then(function() {
      return tokenAddress.balanceOf(account_player1);
    }).then(function(balance) {
      account_player1_starting_balance = balance.toNumber();
      return tokenAddress.approve(meta.address, coinsToAdd, {from: account_player1});
    }).then(function() {
      return meta.depositCoins(coinsToAdd, {from: account_player1});
    }).then(function() {
      return meta.setBet(valueToBet, {from: account_player1});
    }).then(function() {
      return meta.runSpin({from: account_player1});
    }).then(function() {
      return meta.runSpin({from: account_player1});
    }).then(function() {
      return meta.runSpin({from: account_player1});
    }).then(function() {
      return meta.runSpin({from: account_player1});
    }).then(function() {
      return meta.runSpin({from: account_player1});
    }).then(function() {
      return meta.runSpin({from: account_player1});
    }).then(function() {
      return tokenAddress.balanceOf(account_player1);
    }).then(function(balance) {
      account_player1_ending_balance = balance.toNumber();
      // Test validation
      assert(false, "Last fails to shows events"+balance_player1);
     //assert(account_player1_ending_balance > account_player1_starting_balance, "Token Balance of player 1 was not reduced"+balance_player1);
      //assert(account_owner_ending_balance > account_owner_starting_balance, "Ether balance of onwer was not increased"+balance_player1);
    });

  });
});

