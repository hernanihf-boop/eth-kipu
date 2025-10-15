// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IOracle} from "./IOracle.sol";
import {GreatInvestor} from "./GreatInvestor.sol";

contract DonationsV2 is GreatInvestor {

    struct Balances {
        uint256 eth;
        uint256 usdc;
        uint256 total;
    }

    mapping (address => Balances) public balance;

    IOracle public oracle;

    IERC20 immutable public USDC;

    constructor(IOracle _oracle, IERC20 _usdc) GreatInvestor(msg.sender) {
        oracle = _oracle;
        USDC = _usdc;
    }

    function setFeeds(address _feed) external onlyOwner {
        oracle = IOracle(_feed);
    }

    function doeETH() external payable {
        int256 _latestAnswer = _getETHPrice();
        balance[msg.sender].eth += msg.value;
        balance[msg.sender].total += ((msg.value)*uint256(_latestAnswer)); // 18 + 8 = 26
        if (balance[msg.sender].total > 1000*100000000* 1 ether) {
            if (balanceOf(msg.sender) < 1) {
                safeMint(msg.sender, "url");
            }
        }
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
    }

    function saque() external onlyOwner {
        USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
        // saca eth
        (bool success,) = msg.sender.call{value:address(this).balance}("");
        if(!success) revert();
    }

    function _getETHPrice() private view returns(int256 _latestAnswer) {
        return _latestAnswer = oracle.latestAnswer();
    }
}