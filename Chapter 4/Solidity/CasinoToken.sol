pragma solidity ^0.4.24;

import "./contracts/token/ERC20/ERC20.sol";
import "./contracts/token/ERC20/ERC20Detailed.sol";

// CasinoToke - A basic ERC20 Token for a casino game.
contract CasinoToken is ERC20, ERC20Detailed {
	// Set the initia supply value
    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals()));

    // At the deploy sends all the initial supply to the msg.sender.
    constructor () public ERC20Detailed("CasinoToken", "CTK", 18) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}

