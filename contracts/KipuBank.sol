// SPDX-License-Identifier: MIT
pragma solidity > 0.8.0;

contract KipuBankNotFinished {

    error InvalidValue();
    event paid(address indexed  payer, uint256 amount);

    mapping(address=>uint256) public balance; // no se pueden recorrer
    // key => valor

    address[] public addr;


    function pay() external payable {
        if (msg.value != 0.1 ether) revert InvalidValue();
        balance[msg.sender] += msg.value;
        addr.push(msg.sender);
        emit paid(msg.sender, msg.value);
    }
    
   bool flag;
   modifier reentrancyGuard() {
      if(flag != false) revert();
      flag = true;
      _;
      flag = false;
   }


    function withdraw() external reentrancyGuard returns(bytes memory) {
        address to = msg.sender;
        uint256 miBalance = balance[msg.sender];
        balance[msg.sender] = 0;
        (bool success, bytes memory data) = to.call{value: miBalance}("");
        if(!success) revert();
        return data;
    }

    function withdraw2() external{
        address payable to = payable(msg.sender); // send, transfer
        uint256 miBalance = balance[msg.sender];
        balance[msg.sender] = 0;
        to.transfer(miBalance); // gas = 2300
    }

    function withdraw3() external{
        address payable to = payable(msg.sender); // send, transfer
        uint256 miBalance = balance[msg.sender];
        balance[msg.sender] = 0;
        bool success = to.send(miBalance); // gas = 2300
        if (!success) revert();
    }

}