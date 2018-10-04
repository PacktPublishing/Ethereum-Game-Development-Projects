// Defines the compiler version
pragma solidity ^0.4.0;

// Main smart contract code
contract HelloWorld {
    
    // Returns a constant string
    function SayHello() public pure returns(bytes32) {
        return "Hello, World!";
    }

}