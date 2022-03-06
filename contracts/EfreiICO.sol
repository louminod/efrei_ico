// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./EfreiToken.sol";

/**
 * @title ERC20Token
 * @dev API interface for interacting with the ERC20 Token contracts 
 */
interface ERC20Token {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external returns (uint256 balance);
}

contract EfreiICO {
    // Token used by this contract
    ERC20Token token;

    // owner of the contract
    address payable public owner;
    
    // status of the ico
    bool public initialized;

    // ico variables
    uint256 public start;
    uint256 public end;
    uint256 public initialTokensAmount;
    uint256 public rate;
    uint256 public objective;

    // 
    uint256 public raisedAmount;
  
    /**
    * LogBuy
    * @dev Log tokens bought in blockchain
    */
    event LogBuy(address indexed to, uint256 value);

    constructor(
        address _tokenAddress, 
        uint256 _start, 
        uint256 _end, 
        uint256 _initialTokensAmount,
        uint256 _rate,
        uint256 _objective
        ) {
        token = ERC20Token(_tokenAddress);
        start = _start;
        end = _end;
        initialTokensAmount = _initialTokensAmount;
        rate = _rate;
        objective = _objective;

        initialized = false;
        raisedAmount = 0;
        owner = payable(msg.sender);
    }

    // check if the ico is active or not
    modifier isActive() {
        require(
            initialized == true && end > 0 && block.timestamp < end,
            "ICO must be active"
        );
        _;
    }

    // check if the msg.sender is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * startICO
    * @dev Start the contract
    **/
    function startICO() public onlyOwner {
        require(initialized == false, "ICO already initialied"); // Can only be initialized once
        require(tokensAvailable() == initialTokensAmount, "Not enought tokens minted"); // Must have enough tokens minted
        initialized = true;
    }

    /**
    * objectiveReached
    * @dev Function to determin is objective has been reached
    **/
    function objectiveReached() public view returns (bool) {
        return (raisedAmount >= objective * 1 ether);
    }

    /**
    * @dev Fallback function if ether is sent to address insted of buyTokens function
    **/
    receive() external payable {
        buyTokens();
    }

    /**
    * buyTokens
    * @dev function that sells available tokens
    **/
    function buyTokens() public payable isActive {
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount * rate;
        
        emit LogBuy(msg.sender, tokens); // log event onto the blockchain

        raisedAmount = raisedAmount + msg.value; // Increment raised amount

        token.transfer(msg.sender, weiAmount); // Send tokens to buyer
        owner.transfer(msg.value); // Send money to owner
    }

    /**
    * tokensAvailable
    * @dev returns the number of tokens allocated to this contract
    **/
    function tokensAvailable() public returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
    * destroy
    * @notice Terminate contract and refund remaining tokens to owner
    **/
    function destroy() onlyOwner public {
        uint256 balance = token.balanceOf(address(this));
        assert(balance > 0);
        token.transfer(owner, balance);
        selfdestruct(owner); // send ether of contracts to owner
    }
}

