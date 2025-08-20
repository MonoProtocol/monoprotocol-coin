// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {MonoProtocolCoin} from "../src/MonoProtocolCoin.sol";

contract MonoProtocolScript is Script {
    function run() external {
        address daoMultisig = vm.envAddress("DAO_MULTISIG");

        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the contract
        MonoProtocolCoin coin = new MonoProtocolCoin(daoMultisig, "Mono Protocol", "MONO");

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log the deployed address
        console.log("Token deployed at:", address(coin));
    }
}
