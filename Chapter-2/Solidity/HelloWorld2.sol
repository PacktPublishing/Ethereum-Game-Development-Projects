// Defines the compiler version
pragma solidity ^0.4.0;

// Main smart contract code
contract HelloWorld2 {
    // Store the greeting string
    bytes32 public greetings;
    
    // This constrcutor runs once, when you create the smart contract
    constructor() public {
        greetings = "Hello, World!";
    }

    // Returns a constant string
    function SayHello() public pure returns(bytes32) {
        return "Hello, World!";
    }

    // Returns the stored string
    function SayGreetings() public view returns(bytes32) {
        return greetings;
    }
    
    // Set the greeting string
    function SetGreetings(bytes32 _greetingMessage) public {
        greetings = _greetingMessage;
    }
}