// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 _decimals = 8;
    int256 initialAnswer = 2000e8;
    uint256 sepoliaChainID = 11155111;

    struct NetworkConfig {
        address priceFeed; // object that contains ETH/USD price feed address for any network
    }
    NetworkConfig public activeConfig; //Stores the configuration of the current chain being used

    constructor() {
        if (block.chainid == sepoliaChainID) {
            //Checks if the chain id of the block is equal to the chain ID of the Sepolia chain
            activeConfig = getSepoliaETHConfig();
        } else {
            activeConfig = getOrCreateAnvilETHConfig();
        }
    } //Sets the configuration to the pricefeed which is being used

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        //returns the address of the price feed in sepolia which can be used in order to get latest ETH/USD price data
        NetworkConfig memory forSepolia = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        //Creates a new network configuration object and sets the priceFeed address of where it returns data from

        return forSepolia;
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        //returns the address of the price feed in Anvil which can be used in order to get latest ETH/USD price data
        //deploy mocks
        //return mock contract address
        if (activeConfig.priceFeed != address(0)) {
            //Checks if priceFeed has already been set to something
            return activeConfig; //If activeconfig has already been set, just return it
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            _decimals,
            initialAnswer
        ); //Address which gets put into the network config of this function

        vm.stopBroadcast();
        NetworkConfig memory anvilconfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        //Returns a configuration containing the price feed address of the anvil link
        return anvilconfig; //Creates a new anvil config
    }
}
