// Defines the compiler version
pragma solidity ^0.4.24;

import './Library/Ownable.sol';


// Basic Token
contract BasicToken is Ownable {

    string public tokenSymbol;
    string public tokenName;

    // Token balance storage
    mapping(address => uint256) tokenBalances;

    // Token information
    struct CoinBase { // Struct
        string tokenSymbol; // Token symbol
        string tokenName;  // Token name
        uint8 tokenDecimals; // Token decimals
        uint totalTokenSupply; // Token total supply
    }

    // functions to get data from the token
    function getDecimals() public view returns (uint8) {
      return tokenDetails.tokenDecimals;
    }
    
    function getSupply() public view returns (uint) {
      return tokenDetails.totalTokenSupply;
    }

    enum State { Created, Issued, Inactive }

    CoinBase tokenDetails;

    State tokenState;

    // Event to track transfers
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Constructor
    constructor() public {
        tokenState = State.Created;
        tokenDetails = CoinBase("BASIC", "Basic Token", 18, 1000000000);
        tokenSymbol = tokenDetails.tokenSymbol;
        tokenName = tokenDetails.tokenName;
    }

        // Get the token balance for an account
    function issueToken(address ownerAddress) public onlyOwner {
        transferOwnershipTo(ownerAddress);
        tokenBalances[ownerAddress] = tokenDetails.totalTokenSupply;
    }


    // Get the token balance for an account
    function balanceOf(address accountAddress) public view isIssued returns (uint256 balance) {
        return tokenBalances[accountAddress];
    }


    // Transfer token from one account to another one
    function transfer(address toAccount, uint256 tokenAmount) public isIssued returns (bool success) {
      require(tokenState == State.Issued); // Must be issued
      require(tokenAmount > 0); // No zero transfer
      require(tokenAmount <= tokenBalances[msg.sender]); // Need to have funds
      tokenBalances[msg.sender] -= tokenAmount; // Withdraw tokens from sender
      tokenBalances[toAccount] += tokenAmount; // Deposit tokens at destinatary
      emit Transfer(msg.sender, toAccount, tokenAmount); // Produce the tracking event
      return true;
    }

    modifier isIssued {
        require(tokenState == State.Issued,"Token must be issued before use.");
        _;
    }

    // This contract don´t acept ether
    function () public payable {
        revert();
    }

}