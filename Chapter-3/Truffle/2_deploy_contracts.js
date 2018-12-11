var OwnableLib = artifacts.require("./Library/Ownable.sol");
var LotteryGame = artifacts.require("./LotteryGame.sol");

module.exports = function(deployer) {
  deployer.deploy(LotteryGame);
};
