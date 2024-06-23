// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Note: The AggregatorV3Interface might be at a different location than what was in the video!
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundME_NotOwner();
error TooBroke();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    function getNumberOfFunders() public view returns (uint256) {
        return funders.length;
    }

    function getFunder(uint256 position) public view returns (address) {
        return funders[position];
    }

    function getAddresstoAmountFunded(
        address sender
    ) public view returns (uint256) {
        return addressToAmountFunded[sender];
    }

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address price_Feed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(price_Feed); //Takes a pricefeed address as a parameter
    }

    function fund() public payable {
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
            revert TooBroke();
        }

        // require(
        //     msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, //gets the conversion rate from the chain being inputted to USD
        //     "You need to spend more ETH!"
        // );
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundME_NotOwner();
        _;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex]; //takes out a funder address from the array
            addressToAmountFunded[funder] = 0; //Maps the funder address to zero
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send //Throws an error and returns a boolean
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        //Transfers the value of ETH stored IN THE CONTRACT from the function to the account of the owner
        //Returns a boolean whether or not the transaction was successful

        require(callSuccess, "Call failed");
        //If the boolean value is false, this means the transaction was not successful and the function ends
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    function cheaperWithraw() public onlyOwner {
        uint256 noOfFunders = funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < noOfFunders;
            funderIndex++
        ) {
            address funder = funders[funderIndex]; //takes out a funder address from the array
            addressToAmountFunded[funder] = 0; //Maps the funder address to zero
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send //Throws an error and returns a boolean
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        //Transfers the value of ETH stored IN THE CONTRACT from the function to the account of the owner
        //Returns a boolean whether or not the transaction was successful

        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
}
