// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IPermisos {
    function hasPermissions(address _addr) external view returns (bool _permission);
}

contract Token is ERC20 {

    error NoPermission(address _adr);

    IPermisos immutable public permisos;

    constructor(IPermisos _permisos) ERC20("EthKipu", "EKT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
        permisos = _permisos;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        if (!permisos.hasPermissions(to)) revert NoPermission(to);
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        if (!permisos.hasPermissions(to)) revert NoPermission(to);
        return super.transferFrom(from, to, value);
    }
}