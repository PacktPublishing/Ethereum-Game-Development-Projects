pragma solidity ^0.4.24;

import "./contracts/token/ERC20/ERC20.sol";
import "./contracts/token/ERC20/ERC20Detailed.sol";

// CasinoToke - A basic ERC20 Token for a casino game.
contract CasinoToken is ERC20, ERC20Detailed {

	// Our token decimals
	uint8 constant tokenDecimals = 18;

	// Set the initia supply value
    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(tokenDecimals));

    // At the deploy sends all the initial supply to the msg.sender.
    constructor () public ERC20Detailed("CasinoToken", "CTK", tokenDecimals) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}

