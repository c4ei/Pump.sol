// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* ____  _   _ __  __ ____             _ 
  |  _ \| | | |  \/  |  _ \  ___  ___ | |
  | |_) | | | | |\/| | |_) |/ __|/ _ \| |
  |  __/| |_| | |  | |  __/ \__ \ (_) | |
  |_|    \___/|_|  |_|_| (_) ___/\___/|_|
  Degenerate memecoin factory on Ethereum
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MemeTokenFactory {
    address[] public deployedTokens;

    event TokenCreated(
        address tokenAddress,
        string name,
        string symbol,
        string description,
        string image,
        string twitter,
        string telegram,
        string website,
        address developer
    );

    function createToken(
        string memory name,
        string memory symbol,
        string memory description,
        string memory image,
        string memory twitter,
        string memory telegram,
        string memory website
    ) public {
        MemeToken newToken = new MemeToken(name, symbol, description, image, twitter, telegram, website, msg.sender);
        deployedTokens.push(address(newToken));
        emit TokenCreated(address(newToken), name, symbol, description, image, twitter, telegram, website, msg.sender);
    }

    function getDeployedTokens() public view returns (address[] memory) {
        return deployedTokens;
    }
}

contract MemeToken is ERC20 {
    string public description;
    string public image;
    string public twitter;
    string public telegram;
    string public website;
    address public developer;
    uint immutable maxSupply = 1_000_000e18;

    event TokensPurchased(address indexed purchaser, uint amount, uint price);
    event TokensSold(address indexed seller, uint amount, uint price);
    event LiquidityAdded(uint tokenAmount, uint ethAmount);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _image,
        string memory _twitter,
        string memory _telegram,
        string memory _website,
        address _developer
    ) ERC20(_name, _symbol) {
        description = _description;
        image = _image;
        twitter = _twitter;
        telegram = _telegram;
        website = _website;
        developer = _developer;
        _mint(address(this), maxSupply);
    }

    function buyTokens() public payable {
        require(msg.value > 1, "send some ETH");
        uint tokensPerETH = quoteBuy(msg.value);
        uint tokenAmount = msg.value * tokensPerETH / 1e18;
        require(balanceOf(address(this)) > tokenAmount, "sold out");
        _transfer(address(this), msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, tokenAmount, tokensPerETH);
    }

    function sellTokens(uint _tokenAmount) public {
        require(balanceOf(msg.sender) >= _tokenAmount, "too poor");
        uint tokensPerETH = quoteSell(_tokenAmount);
        uint ethAmount = _tokenAmount * 1e18 / tokensPerETH;
        require(address(this).balance >= ethAmount, "Insufficient contract balance");
        _transfer(msg.sender, address(this), _tokenAmount);
        payable(msg.sender).transfer(ethAmount);
        emit TokensSold(msg.sender, _tokenAmount, tokensPerETH);
    }

    function getCurrentPrice() public view returns (uint tokensPerETH) {
        uint remainingTokens = balanceOf(address(this));
        uint contractETHBalance = address(this).balance;
        if (contractETHBalance < 0.01 ether) contractETHBalance =  0.01 ether;
        tokensPerETH = remainingTokens * 1e18 / contractETHBalance;
    }


    function quoteBuy(uint _ethAmount) public view returns (uint tokensPerETH) {
        uint currentTokensPerETH = getCurrentPrice();
        uint tokenAmount = _ethAmount * currentTokensPerETH / 1e18;
        uint remainingTokens = balanceOf(address(this));
        tokensPerETH = (remainingTokens - (tokenAmount / 2)) * 1e18 / (address(this).balance + (_ethAmount / 2));
    }

    function quoteSell(uint _tokenAmount) public view returns (uint tokensPerETH) {
        uint currentTokensPerETH = getCurrentPrice();
        uint ethAmount = _tokenAmount * 1e18 / currentTokensPerETH;
        uint remainingTokens = balanceOf(address(this));
        tokensPerETH = (remainingTokens + (_tokenAmount / 2)) * 1e18 / (address(this).balance - (ethAmount / 2));
    }
}