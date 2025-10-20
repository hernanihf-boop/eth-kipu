// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import {IOracle} from "./IOracle.sol";
import {GreatInvestor} from "./GreatInvestor.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// TODO: Ordenar el contrato (variables, eventos, errores, etc en orden)
// TODO: Comentar variables y métodos usando natSpec.
contract DonationsV2 is GreatInvestor {

    struct Balances {
        uint256 eth;
        uint256 usdc;
        uint256 total;
    }

    mapping (address => Balances) public balance;

    AggregatorV3Interface public dataFeed;

    IERC20 immutable public USDC;

    error InvalidContract();

    event FeedSet(address indexed, uint256 timestamp);
    event Donated(string indexed usdcOrEth, uint256 amountDonated, uint256 amountInUsdc);
    event Extracted(address owner, uint256 valueEth, uint256 valueUsdc);

    constructor(AggregatorV3Interface _dataFeed, IERC20 _usdc) GreatInvestor(msg.sender) {
        if (_dataFeed == AggregatorV3Interface(address(0)) || _usdc == IERC20(address(0))) revert InvalidContract(); 
        dataFeed = _dataFeed; // 0x694AA1769357215DE4FAC081bf1f309aDC325306
        USDC = _usdc;
        emit FeedSet(address(_dataFeed), block.timestamp);
    }

    function setFeeds(address _feed) external onlyOwner {
        dataFeed = AggregatorV3Interface(_feed); // 0x694AA1769357215DE4FAC081bf1f309aDC325306
        emit FeedSet(_feed, block.timestamp);
    }

    function doeETH() external payable {
        // msg.value == 0 => Que sentido tiene todo el resto ? Aca se debería hacer un revert!
        int256 _latestAnswer = _getETHPrice();
        Balances storage _balance = balance[msg.sender]; 

        _balance.eth += msg.value;
        uint256 _donatedInUsdc = ((msg.value)*uint256(_latestAnswer)); // 18 + 8 = 26
         emit Donated("ETH", msg.value, _donatedInUsdc);
        _donatedInUsdc += _balance.total;
        _balance.total += _donatedInUsdc;
        if (_balance.total > 1000*100000000* 1 ether && balanceOf(msg.sender) < 1) {
            safeMint(msg.sender, "url");    
        }
    }

    // doeETH y doeUSDC son similares, se podrían sacar a una función privada y reutilizarlas.
    function doeUSDC(uint256 _usdcAmount) external {
        // Comprobar _usdcAmount que no sea cero !
        USDC.transferFrom(msg.sender, address(this), _usdcAmount);
        balance[msg.sender].usdc += _usdcAmount;
        balance[msg.sender].total += _usdcAmount;
        
        if (balance[msg.sender].total > 1000*100000000* 1 ether && balanceOf(msg.sender) < 1) {
            safeMint(msg.sender, "url");
        }
        emit Donated("USDC", _usdcAmount, _usdcAmount);
    }

    function saque() external onlyOwner {
        // Chequear que el balance (_valueEth / _valueUsdc) exista, que no sea cero!
        uint256 _valueEth = address(this).balance;
        uint256 _valueUsdc = USDC.balanceOf(address(this));
        USDC.transfer(msg.sender, _valueUsdc);
        // saca eth
        (bool success,) = msg.sender.call{value:_valueEth}("");
        if(!success) revert(); // ACá deberíamos mandar el custom error.
        emit Extracted(msg.sender, _valueEth, _valueUsdc);
    }

    function _getETHPrice() private view returns(int256 _latestAnswer) {
        // return _latestAnswer = dataFeed.latestAnswer();
        (,_latestAnswer,,,) = dataFeed.latestRoundData();
        // Verificar la rta del contrato (que no sea cero por ejemplo)!
        return _latestAnswer;
    }
}