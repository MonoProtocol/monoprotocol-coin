// SPDX-License-Identifier: MIT

/* 
 __  __                   ____            _                  _ 
|  \/  | ___  _ __   ___ |  _ \ _ __ ___ | |_ ___   ___ ___ | |
| |\/| |/ _ \| '_ \ / _ \| |_) | '__/ _ \| __/ _ \ / __/ _ \| |
| |  | | (_) | | | | (_) |  __/| | | (_) | || (_) | (_| (_) | |
|_|  |_|\___/|_| |_|\___/|_|   |_|  \___/ \__\___/ \___\___/|_|

*/

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract MonoProtocolCoin is ERC20, ERC20Permit, ERC20Votes, Ownable {
    event OpenBurn(uint256 burnPossibleFromBlock, uint256 amount);

    // Assuming average block time of 12 seconds, this gives approximately 2.5 days
    uint256 private constant BURN_TIMELOCK_BLOCKS = 18000; // 2.5 * 24 * 60 * 60 / 12

    uint256 private _burnPossibleFromBlock;

    constructor(address wallet, string memory name, string memory symbol)
        ERC20(name, symbol)
        ERC20Permit(name)
        Ownable(wallet)
    {
        _mint(wallet, 1000000000000000000000000000);
    }

    function burnInfo() public view returns (uint256 possibleFromBlock, uint256 amount) {
        if (_burnPossibleFromBlock != 0) {
            possibleFromBlock = _burnPossibleFromBlock;
            amount = balanceOf(address(this));
        }
    }

    function openBurn(uint256 amount) external onlyOwner {
        require(_burnPossibleFromBlock == 0, "Burn process already in timelock phase");
        require(amount != 0, "Amount to burn cannot be 0");
        require(amount <= balanceOf(msg.sender), "Not enough tokens to burn");

        transfer(address(this), amount);
        _burnPossibleFromBlock = block.number + BURN_TIMELOCK_BLOCKS;
        emit OpenBurn(_burnPossibleFromBlock, amount);
    }

    function finishBurn() external {
        require(_burnPossibleFromBlock != 0, "Burn process was not initiated");
        require(_burnPossibleFromBlock <= block.number, "Burn process is still in timelock phase");

        _burn(address(this), balanceOf(address(this)));
        _burnPossibleFromBlock = 0;
    }

    function nonces(address owner) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }
}
