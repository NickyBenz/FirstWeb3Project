// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //before broadcast -> Not a real tx
        HelperConfig currentConfig = new HelperConfig();
        vm.startBroadcast();

        FundMe fundMe = new FundMe(currentConfig.activeConfig());
        //Real tx which costs gas!!!
        //Gives the ETH/USD data feed as the address to recieve the latest price of Eth in USD
        vm.stopBroadcast();
        return fundMe;
    }
}
