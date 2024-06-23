//Fund
//Script
//WithDraw
//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script, console} from "../lib/forge-std/src/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundFundMe is Script {
    uint256 send_value = 0.01 ether; //defines a value in storage for the amount being sent

    function sendfunds(address mostRecentlyDeployed) public {
        vm.startBroadcast();

        FundMe(payable(mostRecentlyDeployed)).fund{value: send_value}(); //transfers eth to the fund function of the FundMe address defined
        console.log("FUNDED WITH %s", send_value);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        ); //stores the contract address of the most recent deployment of the FundMe contract

        sendfunds(mostRecentlyDeployed); //Sends money to that FundMe contract
    }
}

contract WithDrawFundMe is Script {
    function withdrawfunds(address mostRecentlyDeployed) public {
        vm.startBroadcast();

        FundMe((payable(mostRecentlyDeployed))).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        ); //Stores the contract address of the most recently deployed fund

        withdrawfunds(mostRecentlyDeployed);
    }
}
