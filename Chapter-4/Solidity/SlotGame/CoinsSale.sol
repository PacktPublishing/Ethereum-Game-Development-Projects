pragma solidity ^0.4.24;

import "./contracts/token/ERC20/IERC20.sol";
import "./contracts/math/SafeMath.sol";
import "./contracts/token/ERC20/SafeERC20.sol";
import "./contracts/utils/ReentrancyGuard.sol";
import "./contracts/ownership/Ownable.sol";

// Allows to sell Tokens to players
// Note that you must send tokens to this contract to be able to sell
contract CoinsSale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint8 constant initalExchangeRate = 1;
    bool constant initalweiToToken = true;

    // The casino token to sold
    //IERC20 private casinoToken;
    address private casinoTokenAddress;

    IERC20 private casinoToken;

    // Address to receive sales funds
    address private casinoWallet;

    // Is the value in Casino Token units you get from 1 wei
    uint256 private exchangeRate; 
    // If true exchangeRate is the value in Casino Token units you get from 1 wei
    // If false exchangeRate is the value in wei you get from Casino Token units
    bool private weiToToken;

    // Amount sold in wei
    uint256 private amountSold;

    // Event for casino token purchases
    event CasinoTokensPurchased(address indexed purchaser, address indexed destination, uint256 weiValue, uint256 tokenValue);

    // At the deploy define exchange rate, where to send the funds, and our Cosino Token address
    constructor () public {
        exchangeRate = initalExchangeRate;
        weiToToken = initalweiToToken;
    }

    // Public functions
    // Get casino token address
    function getToken() public view returns (address) {
        return casinoTokenAddress;
    }

    // Get exchange rate
    function getExchangeRate() public view returns (uint256) {
        return exchangeRate;
    }

    // Owner functions
    // Set a new exchange rate
    function setRate(uint256 _newExchangeRate, bool _weiToToken) public onlyOwner {
        require(_newExchangeRate > 0, "Exchange rate can not be zero.");
       exchangeRate = _newExchangeRate;
        weiToToken = _weiToToken;
    }

    // Set the casino wallet address
    function setWallet(address _wallet) public onlyOwner {
        require(_wallet != address(0));
        casinoWallet = _wallet;
    }

    // Set the token address
    function setToken(address _casinoToken) public onlyOwner {
        require(_casinoToken != address(0));
        casinoTokenAddress = _casinoToken;
        casinoToken = IERC20(casinoTokenAddress);
    }

    // Get casino wallet address
    function getWallet() public onlyOwner view returns (address) {
        return casinoWallet;
    }

    // Get total sold
    function getSales() public onlyOwner view returns (uint256) {
        return amountSold;
    }

    // Direct purchase function
    function () external payable {
        buyCasinoTokensFor(msg.sender);
    }

    function buyCasinoTokens() public payable {
         buyCasinoTokensFor(msg.sender);
    }

    // Buy casino tokens. If you call directly you can buy tokens for another player
    function buyCasinoTokensFor(address _destination) public nonReentrant payable {
        require(_destination != address(0), "Destination can not be zero address.");
        require(msg.value != 0, "Value must be greater than zero.");
        require(casinoToken.balanceOf(this) > convertEtherToToken(msg.value), "Machine out of tokens to sell");

        // Get the amount sent
        uint256 purchaseAmount = msg.value;
        
        // Convert wei in casino tokens
        uint256 tokenAmount = convertEtherToToken(purchaseAmount);

        // update total sold
        amountSold = amountSold.add(purchaseAmount);

        // Send tokens to user
        casinoToken.safeTransfer(_destination, tokenAmount);

        // Emit event to log transaction
        emit CasinoTokensPurchased(msg.sender, _destination, purchaseAmount, tokenAmount);

        casinoWallet.transfer(msg.value);
    }

    function convertEtherToToken(uint256 _ethAmount) internal view returns (uint256) {
        // If true exchangeRate is the value in Casino Token units you get from 1 wei
        if (weiToToken) {
            return _ethAmount.mul(exchangeRate);
        }
        // If false exchangeRate is the value in wei you get from Casino Token units
        return _ethAmount.div(exchangeRate);

    }
}

