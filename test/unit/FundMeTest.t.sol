// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "../../lib/forge-std/src/Test.sol";
import "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 curr_version = 4;
    uint256 testAmount = 1e18;
    uint256 start_balance = 1e18;
    uint256 expectedfail_balance = 0.001 ether;
    address SOME_BROKE_GUY = makeAddr("some_broke_guy"); //Makes a new address which can be used for all tests
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //runs first
        DeployFundMe deployFundMe = new DeployFundMe(); //Creates a new DeployFundMe contract (essentally creates an object)
        fundMe = deployFundMe.run(); //sets the fundMe value in the test environment to the fundMe value that is returned in deployFundMe
    }

    function testMinimumDollar() public view {
        //runs second
        // assertEQ tests if two values are equal and throws an error if they are not
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log(
            "Congratulations, you have just tested an operation in Solidity"
        );
    }

    function testOwnerisMessageSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, curr_version);
    }

    function testFundRevertsWhenNotEnoughUSD() public {
        vm.deal(SOME_BROKE_GUY, start_balance); //deal the address of this senter some eth

        vm.expectRevert(TooBroke.selector); //Tells the next line to revert
        vm.prank(SOME_BROKE_GUY); //Calls the function using this sender address
        fundMe.fund{value: expectedfail_balance}(); //sends the 'fund' function soem eth
    }

    modifier funded() {
        vm.deal(SOME_BROKE_GUY, start_balance);
        _;
    }

    function testifDatastructuresupdates() public funded {
        vm.prank(SOME_BROKE_GUY);
        fundMe.fund{value: start_balance}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, SOME_BROKE_GUY);
    }

    function testifOnlyOwnercanWithdraw() public {
        vm.expectRevert(FundME_NotOwner.selector);
        vm.prank(SOME_BROKE_GUY);
        fundMe.withdraw();
    }

    function testCheaperWithDrawWithASingleFunder() public funded {
        uint256 owner_balance = fundMe.getOwner().balance;
        uint256 contract_balance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithraw();
        uint256 final_balance = owner_balance + contract_balance;
        assertEq(owner_balance, final_balance);
    }

    function testWithDrawWithASingleFunder() public funded {
        uint256 owner_balance = fundMe.getOwner().balance;
        uint256 contract_balance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 final_balance = owner_balance + contract_balance;
        assertEq(owner_balance, final_balance);
    }

    function testWithdrawWithManyFunders() public funded {
        //Arrange -Setting up the test
        uint256 noOfFunders = 10;
        uint256 startindex = 2;
        uint160 addressgenerator = 0;
        for (uint256 i = startindex; i < noOfFunders; ++i) {
            address testaddress = address(addressgenerator);
            hoax(testaddress, start_balance); //gives an address some fake eth to a fake address created and deploys using that address
            fundMe.fund{value: start_balance}(); //funds the contract
            addressgenerator++;
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithraw();
        vm.stopPrank();
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;
        //Assert
        assertEq(endingContractBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingContractBalance
        );
    }
}
