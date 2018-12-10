// Defines the compiler version
pragma solidity ^0.4.24;

// Main Ownable contract
contract Ownable {

  address private _owner; // Owner address

  // constructor that sets de owner as the one that deployed the contract
  constructor() internal {
    _owner = msg.sender;
  }

  // Requires the sender be the owner 
  modifier onlyOwner() {
    require(isOwner(), "You must be the owner");
    _;
  }

  // Gets the owner
  function getOwner() public view returns(address) {
    return _owner;
  }

  // returns true of sender is the owner
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  // The owner can transfer the ownnership to a new account
  function transferOwnershipTo(address newOwner) public onlyOwner {
    _owner = newOwner;
  }
}
