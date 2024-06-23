//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "../../lib/forge-std/src/Test.sol";
import "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithDrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeIntegrationTest is Test {
    FundMe fundMe;
    uint256 curr_version = 4;
    uint256 testAmount = 1e18;
    uint256 start_balance = 1e18;
    uint256 expectedfail_balance = 0.001 ether;
    address SOME_BROKE_GUY = makeAddr("some_broke_guy"); //Makes a new address which can be used for all tests
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(SOME_BROKE_GUY, start_balance);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundme = new FundFundMe();
        fundFundme.sendfunds(address(fundMe));
        WithDrawFundMe withdrawfundme = new WithDrawFundMe();
        withdrawfundme.withdrawfunds(address(fundMe));

        assert(address(fundMe).balance == 0); //Checks if balance is zero after withdraw
    }
}
