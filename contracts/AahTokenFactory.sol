// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    AahTokenFactory.sol
    Upgradeable Degenerate Aahcoin Factory on AAH
*/

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract AahTokenFactory is Initializable, UUPSUpgradeable {
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

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __UUPSUpgradeable_init();
    }

    function createToken(
        string memory name,
        string memory symbol,
        string memory description,
        string memory image,
        string memory twitter,
        string memory telegram,
        string memory website
    ) public {
        AahToken newToken = new AahToken();
        newToken.initialize(name, symbol, description, image, twitter, telegram, website, msg.sender);
        deployedTokens.push(address(newToken));
        emit TokenCreated(
            address(newToken),
            name,
            symbol,
            description,
            image,
            twitter,
            telegram,
            website,
            msg.sender
        );
    }

    function getDeployedTokens() public view returns (address[] memory) {
        return deployedTokens;
    }

    function _authorizeUpgrade(address newImplementation) internal override {}
}

contract AahToken is Initializable, ERC20Upgradeable, UUPSUpgradeable {
    string public description;
    string public image;
    string public twitter;
    string public telegram;
    string public website;
    address public developer;
    uint256 immutable maxSupply = 1_000_000e18;

    event TokensPurchased(address indexed purchaser, uint256 amount, uint256 price);
    event TokensSold(address indexed seller, uint256 amount, uint256 price);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _image,
        string memory _twitter,
        string memory _telegram,
        string memory _website,
        address _developer
    ) public initializer {
        __ERC20_init(_name, _symbol);
        __UUPSUpgradeable_init();

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
        uint256 tokensPerETH = quoteBuy(msg.value);
        uint256 tokenAmount = (msg.value * tokensPerETH) / 1e18;
        require(balanceOf(address(this)) > tokenAmount, "sold out");
        _transfer(address(this), msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, tokenAmount, tokensPerETH);
    }

    function sellTokens(uint256 _tokenAmount) public {
        require(balanceOf(msg.sender) >= _tokenAmount, "too poor");
        uint256 tokensPerETH = quoteSell(_tokenAmount);
        uint256 ethAmount = (_tokenAmount * 1e18) / tokensPerETH;
        require(address(this).balance >= ethAmount, "Insufficient contract balance");
        _transfer(msg.sender, address(this), _tokenAmount);
        payable(msg.sender).transfer(ethAmount);
        emit TokensSold(msg.sender, _tokenAmount, tokensPerETH);
    }

    function getCurrentPrice() public view returns (uint256 tokensPerETH) {
        uint256 remainingTokens = balanceOf(address(this));
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance < 0.01 ether) contractETHBalance = 0.01 ether;
        tokensPerETH = (remainingTokens * 1e18) / contractETHBalance;
    }

    function quoteBuy(uint256 _ethAmount) public view returns (uint256 tokensPerETH) {
        uint256 currentTokensPerETH = getCurrentPrice();
        uint256 tokenAmount = (_ethAmount * currentTokensPerETH) / 1e18;
        uint256 remainingTokens = balanceOf(address(this));
        tokensPerETH = ((remainingTokens - (tokenAmount / 2)) * 1e18) / (address(this).balance + (_ethAmount / 2));
    }

    function quoteSell(uint256 _tokenAmount) public view returns (uint256 tokensPerETH) {
        uint256 currentTokensPerETH = getCurrentPrice();
        uint256 ethAmount = (_tokenAmount * 1e18) / currentTokensPerETH;
        uint256 remainingTokens = balanceOf(address(this));
        tokensPerETH = ((remainingTokens + (_tokenAmount / 2)) * 1e18) / (address(this).balance - (ethAmount / 2));
    }

    function _authorizeUpgrade(address newImplementation) internal override {}
}
