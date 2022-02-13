// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./EfreiToken.sol";

contract EfreiICO {
    struct Sale {
        address investor;
        uint256 amount;
        bool tokensWithdrawn;
    }

    mapping(address => Sale) public sales;
    address public admin;

    uint256 public end;
    uint256 public duration;
    uint256 public price;
    uint256 public availableTokens;
    uint256 public minPurchase;
    uint256 public maxPurchase;

    EfreiToken public token;

    IERC20 public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    constructor(
        address tokenAddress,
        uint256 _duration,
        uint256 _price,
        uint256 _availableTokens,
        uint256 _minPurchase,
        uint256 _maxPurchase
    ) {
        token = EfreiToken(tokenAddress);

        admin = msg.sender;
        duration = _duration;
        price = _price;
        availableTokens = _availableTokens;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
    }

    function start() external onlyAdmin icoNotActive {
        end = block.timestamp + duration;
    }

    function buy(uint256 daiAmount) external icoActive {
        require(
            daiAmount >= minPurchase && daiAmount <= maxPurchase,
            "have to buy between minPurchase and maxPurchase"
        );
        uint256 tokenAmount = daiAmount / price;
        require(
            tokenAmount <= availableTokens,
            "Not enough tokens left for sale"
        );
        dai.transferFrom(msg.sender, address(this), daiAmount);
        token.mint(address(this), tokenAmount);
        sales[msg.sender] = Sale(msg.sender, tokenAmount, false);
    }

    function withdrawTokens() external icoEnded {
        Sale storage sale = sales[msg.sender];
        require(sale.amount > 0, "only investors");
        require(sale.tokensWithdrawn == false, "tokens were already withdrawn");
        sale.tokensWithdrawn = true;
        token.transfer(sale.investor, sale.amount);
    }

    function withdrawDai(uint256 amount) external onlyAdmin icoEnded {
        dai.transfer(admin, amount);
    }

    modifier icoActive() {
        require(
            end > 0 && block.timestamp < end && availableTokens > 0,
            "ICO must be active"
        );
        _;
    }

    modifier icoNotActive() {
        require(end == 0, "ICO should not be active");
        _;
    }

    modifier icoEnded() {
        require(
            end > 0 && (block.timestamp >= end || availableTokens == 0),
            "ICO must have ended"
        );
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }
}
