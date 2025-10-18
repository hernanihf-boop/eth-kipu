// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import {IOracle} from "./IOracle.sol";
import {GreatInvestor} from "./GreatInvestor.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract DonationsV2 is GreatInvestor {

    struct Balances {
        uint256 eth;
        uint256 usdc;
        uint256 total;
    }

    mapping (address => Balances) public balance;

    AggregatorV3Interface public dataFeed;

    IERC20 immutable public USDC;

    event FeedSet(address indexed, uint256 timestamp);
    event Donated(string indexed usdcOrEth, uint256 amountDonated, uint256 amountInUsdc);
    event Extracted(address owner, uint256 valueEth, uint256 valueUsdc);

    constructor(AggregatorV3Interface _dataFeed, IERC20 _usdc) GreatInvestor(msg.sender) {
        dataFeed = _dataFeed; // 0x694AA1769357215DE4FAC081bf1f309aDC325306
        USDC = _usdc;
        emit FeedSet(address(_dataFeed), block.timestamp);
    }

    function setFeeds(address _feed) external onlyOwner {
        dataFeed = AggregatorV3Interface(_feed); // 0x694AA1769357215DE4FAC081bf1f309aDC325306
        emit FeedSet(_feed, block.timestamp);
    }

    function doeETH() external payable {
        int256 _latestAnswer = _getETHPrice();
        balance[msg.sender].eth += msg.value;
        uint256 _donatedInUsdc = ((msg.value)*uint256(_latestAnswer)); // 18 + 8 = 26
        balance[msg.sender].total += _donatedInUsdc;
        if (balance[msg.sender].total > 1000*100000000* 1 ether) {
            if (balanceOf(msg.sender) < 1) {
                safeMint(msg.sender, "url");
            }
        }
        emit Donated("ETH", msg.value, _donatedInUsdc);
    }

    function doeUSDC(uint256 _usdcAmount) external {
        USDC.transferFrom(msg.sender, address(this), _usdcAmount);
        balance[msg.sender].usdc += _usdcAmount;
        balance[msg.sender].total += _usdcAmount;
        safeMint(msg.sender, "url");
        if (balance[msg.sender].total > 1000*100000000* 1 ether) {
            if (balanceOf(msg.sender) < 1) {
                safeMint(msg.sender, "url");
            }
        }
        emit Donated("USDC", _usdcAmount, _usdcAmount);
    }

    function saque() external onlyOwner {
        uint256 _valueEth = address(this).balance;
        uint256 _valueUsdc = USDC.balanceOf(address(this));
        USDC.transfer(msg.sender, _valueUsdc);
        // saca eth
        (bool success,) = msg.sender.call{value:_valueEth}("");
        if(!success) revert();
        emit Extracted(msg.sender, _valueEth, _valueUsdc);
    }

    function _getETHPrice() private view returns(int256 _latestAnswer) {
        // return _latestAnswer = dataFeed.latestAnswer();
        (,_latestAnswer,,,) = dataFeed.latestRoundData();
        return _latestAnswer;
    }
}