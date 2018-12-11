var Library1 = artifacts.require("./contracts/access/Roles.sol");
var Library2 = artifacts.require("./contracts/access/roles/CapperRole.sol");
var Library3 = artifacts.require("./contracts/access/roles/MinterRole.sol");
var Library4 = artifacts.require("./contracts/access/roles/PauserRole.sol");
var Library5 = artifacts.require("./contracts/access/roles/SignerRole.sol");
var Library6 = artifacts.require("./contracts/math/SafeMath.sol");
var Library7 = artifacts.require("./contracts/ownership/Ownable.sol");
var Library8 = artifacts.require("./contracts/ownership/Ownable.sol");
var Library9 = artifacts.require("./contracts/token/ERC20/ERC20.sol");
var Library10 = artifacts.require("./contracts/token/ERC20/ERC20Detailed.sol");
var Library11 = artifacts.require("./contracts/token/ERC20/IERC20.sol");
var Library12 = artifacts.require("./contracts/token/ERC20/SafeERC20.sol");
var Library13 = artifacts.require("./contracts/utils/ReentrancyGuard.sol");

var CasinoToken = artifacts.require("./CasinoToken.sol");
var CoinsSale = artifacts.require("./CoinsSale.sol");
var SlotMachine = artifacts.require("./SlotMachine.sol");

module.exports = function(deployer) {
  deployer.deploy(CasinoToken);
  deployer.deploy(CoinsSale);
  deployer.deploy(SlotMachine);
};
