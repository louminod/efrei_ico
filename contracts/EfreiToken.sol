// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EfreiToken is ERC20 {
    address public admin;
    uint256 public maxTotalSupply;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxTotalSupply
    ) ERC20(_name, _symbol) {
        admin = msg.sender;
        maxTotalSupply = _maxTotalSupply;
    }

    function mint(address account, uint256 amount) external onlyAdmin {
        uint256 totalSupply = totalSupply();
        require(
            totalSupply + amount <= maxTotalSupply,
            "above maxTotalSupply limit"
        );
        _mint(account, amount);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }
}
