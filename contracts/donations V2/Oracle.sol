// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

//import {IOracle} from "./IOracle.sol";
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract Oracle {
    /*
    function latestAnswer() external pure returns(int256) {
        return 411788170000;
    }
    */
    function latestRoundData() 
    external 
    pure 
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) {
        return (0, 411788170000, 0, 0, 0);
    }
}