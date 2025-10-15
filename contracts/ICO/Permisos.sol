// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Permisos is Ownable {

    mapping (address => bool) public blacklist;
    IERC20 public token;
    address public ICO;


    event BlacklistSet(address indexed  whoSet, address indexed whoWasSet);
    event TokenSet(IERC20 token);

    constructor() Ownable(msg.sender) {}

    function setICO(address _ICO) external onlyOwner {
        ICO = _ICO;
    }

    function setToken(IERC20 _token) external onlyOwner{
        token = _token;
        emit TokenSet(_token);
    }

    function setBlacklist(address _addr, bool _permision) external onlyOwner {
        blacklist[_addr] = _permision;
        emit BlacklistSet(msg.sender, _addr);
    }

    function hasMoreThan100Tokens(address _addr) public view returns (bool _hasOrNot) {
        uint256 balance = token.balanceOf(_addr);
        return balance > (100 * 10**18) ? true: false;
    }

    function isBlacklisted(address _addr) public view returns (bool) {
        return blacklist[_addr];
    }

    function hasPermision(address _addr) external view returns (bool _permision) {
        if(_addr == ICO) {
            return true;
        }
        if (hasMoreThan100Tokens(_addr) || isBlacklisted(_addr)){
            return false;
        } else {
            return true;
        }
    }
}