// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ICO {

    error TransferFailed();
    event TokenSold(address indexed who, uint256 amount);
    event TokenBought(address indexed who, uint256 amount);

    IERC20 immutable public token;
    uint256 immutable public price;

    constructor(IERC20 _token, uint256 _price) {
        token = _token;
        price = _price;
    }

    function buy() external payable {
        uint256 amount = msg.value / price;
        token.transfer(msg.sender, amount);
        emit TokenBought(msg.sender, amount);
    }

    function sell(uint256 _amount) external {
        uint256 etherAmount = (_amount * price * 98) / 100;
        token.transferFrom(msg.sender, address(this), _amount);
        //payable(msg.sender).transfer(etherAmount); 
        // recomendation => msg.sender.call(value:etherAmount) {""};
        (bool success,) = msg.sender.call{value: etherAmount} ("");
        if (!success) revert TransferFailed();
        emit TokenSold(msg.sender, etherAmount);
    }
}