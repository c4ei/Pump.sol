# Pump.sol

## Degenerate Memecoin Factory On Ethereum

The **MemeTokenFactory** and **MemeToken** contracts allow developers and users to create, buy, and sell tokens with a dynamic pricing mechanism on the Ethereum blockchain. This factory-based approach enables the deployment of custom ERC-20 tokens, specifically designed for memecoins, with features for token purchase, sales, and price adjustment based on the contract's ETH balance and token supply.

### Key Features:
- **Token Creation**: Users can create their own ERC-20 token with custom properties (name, symbol, description, image, social links).
- **Dynamic Pricing**: Token price changes dynamically depending on the contract's ETH balance, becoming more expensive as more ETH is added.
- **Buy and Sell Mechanism**: Users can buy tokens with ETH or sell tokens back to the contract to receive ETH.
- **Liquidity Tracking**: Events are emitted to track purchases, sales, and liquidity changes.

---

## Contracts

### 1. MemeTokenFactory

This contract is responsible for creating new `MemeToken` instances. When a user calls `createToken()`, a new `MemeToken` contract is deployed with the provided information. The created tokens are stored in an array accessible via `getDeployedTokens()`.

#### Key Functions:

- `createToken(string name, string symbol, string description, string image, string twitter, string telegram, string website)`: Creates a new `MemeToken` and stores its address.
- `getDeployedTokens()`: Returns a list of all deployed token addresses.

### 2. MemeToken (ERC-20)

This contract is the core ERC-20 token contract for each memecoin. It has a dynamic pricing mechanism where the price per token increases as more ETH is added to the contract. It also allows users to buy and sell tokens directly from the contract.

#### Key Variables:

- `description`, `image`, `twitter`, `telegram`, `website`: Metadata associated with the token.
- `developer`: The address that created the token.
- `maxSupply`: The maximum supply of tokens (1,000,000 tokens).

#### Key Functions:

- **Purchasing Tokens**:
  - `buyTokens()`: Allows users to send ETH and receive tokens based on the current price.
  
- **Selling Tokens**:
  - `sellTokens(uint _tokenAmount)`: Allows users to sell their tokens back to the contract and receive ETH based on the current price.

- **Pricing**:
  - `getCurrentPrice()`: Returns the current price (tokens per ETH) based on the contract's token and ETH balances.
  - `quoteBuy(uint _ethAmount)`: Calculates how many tokens the user would get for a given amount of ETH.
  - `quoteSell(uint _tokenAmount)`: Calculates how much ETH the user would get for selling a given amount of tokens.

---

## Deployment

To deploy the `MemeTokenFactory` contract on Ethereum, follow these steps:

1. **Compile the Contract**:
   ```bash
   npx hardhat compile
   ```

2. **Deploy the Contract**:
   Create a deployment script (e.g., `deploy.js`) and deploy it using Hardhat:
   ```javascript
   async function main() {
       const MemeTokenFactory = await ethers.getContractFactory("MemeTokenFactory");
       const factory = await MemeTokenFactory.deploy();
       console.log("MemeTokenFactory deployed to:", factory.address);
   }
   main().catch((error) => {
       console.error(error);
       process.exitCode = 1;
   });
   ```

   Run the script:
   ```bash
   npx hardhat run scripts/deploy.js --network <network_name>
   ```

---

## Usage

### 1. Create a MemeToken

```solidity
function createToken(
    string memory name, 
    string memory symbol, 
    string memory description, 
    string memory image, 
    string memory twitter, 
    string memory telegram, 
    string memory website
) public;
```
This will emit a `TokenCreated` event with the new token's address and associated data.

### 2. Buy Tokens

Users can send ETH to buy tokens by calling the `buyTokens()` function in the `MemeToken` contract. The number of tokens they receive depends on the current price, which increases as the contract’s ETH balance grows.

```solidity
function buyTokens() public payable;
```

### 3. Sell Tokens

Users can sell their tokens back to the contract using the `sellTokens()` function.

```solidity
function sellTokens(uint _tokenAmount) public;
```

### 4. Get Token Pricing

- Get the current token price in terms of tokens per ETH:
  ```solidity
  function getCurrentPrice() public view returns (uint);
  ```

- Get a quote for buying tokens with a given ETH amount:
  ```solidity
  function quoteBuy(uint _ethAmount) public view returns (uint);
  ```

- Get a quote for selling a given amount of tokens:
  ```solidity
  function quoteSell(uint _tokenAmount) public view returns (uint);
  ```

---

## Events

- **TokenCreated**: Emitted when a new `MemeToken` is created.
  ```solidity
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
  ```

- **TokensPurchased**: Emitted when tokens are purchased.
  ```solidity
  event TokensPurchased(address indexed purchaser, uint amount, uint price);
  ```

- **TokensSold**: Emitted when tokens are sold.
  ```solidity
  event TokensSold(address indexed seller, uint amount, uint price);
  ```

- **LiquidityAdded**: Emitted when liquidity is added.
  ```solidity
  event LiquidityAdded(uint tokenAmount, uint ethAmount);
  ```

---

## License

This project is licensed under the MIT License.