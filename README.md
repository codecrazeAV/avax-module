# Introduction to Avalanche
Avalanche has become increasingly popular due to the platform's unique features. As the first decentralized smart contracts platform built for the scale of global finance, Avalanche offers near-instant transaction finality, low fees, and high scalability. The Avalanche platform is composed of multiple "chains" or subnets:

- *Exchange Chain*, or the X-Chain, is responsible for operations on digital smart assets known as Avalanche Native Tokens.

- *Contract Chain*, or the C-Chain, is an implementation of the Ethereum Virtual Machine (EVM) and supports the creation and execution of smart contracts written in Solidity.

- *Platform Chain*, or the P-Chain, supports the creation of new blockchains and Subnets, the addition of validators to Subnets, staking operations, and other platform-level operations.

The Avalanche network has its native token called AVAX, the native token secures the network, pays for fees, and provides the basic unit of account between the multiple blockchains deployed on the larger Avalanche network.

In this guide we are going to set up a basic project using the [Hardhat](https://hardhat.org/), we are going to connect it to the Avalanche C-Chain and we are going to deploy a WAVAX (ERC20) smart contract, we are going to interact with it on [Snowtrace](https://snowtrace.io/) (Avalanche's native block explorer) and using custom scripts on Hardhat.

## Avalanche X-Chain
The X-Chain is responsible for operations on digital smart assets known as Avalanche Native Tokens. These tokens could be used to represent a wide range of assets, including cryptocurrencies, stocks, bonds, and real estate. The [X-Chain API](https://docs.avax.network/apis/avalanchego/apis/x-chain) provides a simple and easy-to-use interface for creating and trading these tokens.

One of the key benefits of the X-Chain is its high throughput and low transaction fees. Additionally, the X-Chain supports atomic swaps, which allow users to exchange one asset for another without the need for a centralized exchange or intermediary.

## Avalanche P-Chain
The P-Chain is a platform chain on Avalanche, responsible for the creation and management of new blockchains and subnets, the addition of validators to subnets, and other platform-level operations. The P-Chain is also responsible for staking operations, which are used to secure the network and maintain consensus across all the subnets on the Avalanche network.

Staking on the P-Chain involves locking up AVAX tokens as collateral to become a validator, or delegating AVAX tokens to an existing validator to participate in the consensus process. Validators are responsible for verifying transactions and adding new blocks to the chain and are rewarded with AVAX tokens for their work.

In addition to staking, the P-Chain also supports the creation of custom subnets, which are separate chains that can have their own unique set of rules and parameters. These subnets can be used for a variety of purposes, such as creating private networks or implementing specialized execution environments.

Overall, the P-Chain is a key component of the Avalanche platform, providing the infrastructure and governance mechanisms necessary to maintain a secure and decentralized network.

The P-Chain is an instance of the Platform Virtual Machine. The [P-Chain API](https://docs.avax.network/apis/avalanchego/apis/p-chain) supports the creation of new blockchains and Subnets, the addition of validators to Subnets, staking operations, and other platform-level operations.

## Avalanche C-Chain
The C-Chain is an implementation of the Ethereum Virtual Machine (EVM), which means that it supports the creation and execution of smart contracts written in Solidity. This makes it easy for developers who are already familiar with Ethereum to build and deploy decentralized applications (dApps) on Avalanche.

One of the key benefits of the C-Chain is its high performance and low transaction fees. With its sub-second finality and low gas fees, the C-Chain can support a wide range of dApps with high transaction volumes.

The C-Chain also supports interoperability with other blockchains, including Ethereum, through the use of cross-chain bridges. This means that assets and data can be transferred between the two chains, opening up new possibilities for decentralized finance (DeFi) and other use cases.

The [C-Chain API](https://docs.avax.network/apis/avalanchego/apis/x-chain) provides a similar interface to the Ethereum JSON-RPC API, making it easy for developers to interact with the C-Chain using their existing tools and libraries.

In this guide we're going to interact with the C-Chain, we need to create an ERC20 token to represent Degen Tokens for a gaming studio, we want to enable the studio to mint these tokens according to their needs, so we also need to add simple mint function to our smart contract to mint these tokens to a specific address. We are going to cover all of that in this guide.

### Setup
We need to create a Hardhat project, the process is straightforward but we are going to recap just for a summary.

1. Create a folder for your new project, and run `npm init`
```bash
$ cd ./your-project
$ npm init -y
```

2. Install hardhat
```bash
$ npm install --save-dev hardhat
```

3. Initialize your hardhat project
```bash
$ npx hardhat
888    888                      888 888               888
888    888                      888 888               888
888    888                      888 888               888
8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
888    888 .d888888 888    888  888 888  888 .d888888 888
888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888

👷 Welcome to Hardhat v2.9.9 👷‍

? What do you want to do? …
❯ Create a JavaScript project
  Create a TypeScript project
  Create an empty hardhat.config.js
  Quit
```
We are going to use JavaScript for this guide but feel free to use TypeScript if you are familiar with it.

## Smart contract
For the smart contract section, we are going to create a Degen ERC20 token using OpenZeppelin, and we are going to make it mintable.

First, we need to install OpenZeppelin, OpenZeppelin is a library for secure smart contract development, build on a solid foundation of community-vetted code.

```bash
$ npm install @openzeppelin/contracts
```

After that is completely inside the `contracts` folder we are going to create a `DegenToken.sol` file, and put the following contents inside of it:

```sol
//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {

constructor()ERC20("DegenToken", "DGT") {
}
mapping(address => bool) private  isWhitelisted;
function mint(address to, uint256 amount) public onlyOwner{
    _mint(to, amount);
}
mapping (address=>uint256) public DGT_Gold_balance;
mapping (address=>uint256) public DGT_Diamond_balance;

function transfertokens(address to, uint256 amount) external {
    require(isWhitelisted[msg.sender] || msg.sender == to, "Only whitelisted addresses or sender can transfer tokens");
    require(balanceOf(msg.sender)>=amount,"Not enough balance");
     _transfer(msg.sender, to, amount);
}

function burn(uint256 amount) public onlyOwner{
    require(balanceOf(msg.sender)>=amount,"Not enough balance");
    _burn(msg.sender, amount);
}

function checkBalance(address account) public view returns (uint256) {
    return balanceOf(account);
}

function Redeem(uint256 choice, uint256 number) external{
    require(isWhitelisted[msg.sender], "Only whitelisted addresses can redeem tokens");
    if(choice==1){
        require(balanceOf(msg.sender)>=number*100,"Not enough balance");
       _burn(msg.sender,number*100);
       DGT_Gold_balance[msg.sender]+=number;
    }
    if(choice==2){
        require(balanceOf(msg.sender)>=number*1000,"Not enough balance");
        _burn(msg.sender, number*1000);
        DGT_Diamond_balance[msg.sender]+=number;
    }
}

function Store(uint256 choice) public pure returns(string memory) {
    if(choice==1){
        return "You have entered choice 1: DGT gold of worth 100 DGT";
    }
    else if(choice==2)
    return "You have entered choice 2: DGT diamond, worth 1000 DGT";
    else 
    return "Invalid Input choose between 1 and 2";
}

function addWhitelistedAddress(address addressk) public onlyOwner {
    isWhitelisted[addressk] = true;
}

function removeWhitelistedAddress(address addressk) public onlyOwner {
    isWhitelisted[addressk] = false;
}
}
```

That would be it for the smart contract side, now we need to configure Hardhat to work with the Avalanche C-Chain.

## Configuration
To configure Harhat to work with Avalanche by default, the first step is to add Avalanche to its supported chains. For initial testing purposes, we will be using Avalanche's Fuji test network, which is a C-Chain test network that allows us to test our smart contracts. Once everything is thoroughly tested and working as expected, we can then proceed by deploying it to Avalanche's Mainnet.

To accomplish this, we need to follow the steps below.

We need to add Avalanche as a supported network in Harhat's configuration. This can be done by modifying the configuration file to include the necessary parameters for Avalanche.

When using the hardhat network, you may choose to fork Fuji or Avalanche Mainnet, this will allow you to debug contracts using the hardhat network while keeping the current network state. To enable forking, turn one of these booleans on, and then run your tasks/scripts using `--network hardhat`

Add the following code to our `hardhat.config.js` file, this will enable us to test our smart contracts on the local network with data from Avalanche Mainnet.

```js
// ...

const FORK_FUJI = false
const FORK_MAINNET = false
let forkingData = undefined;

if (FORK_MAINNET) {
  forkingData = {
    url: 'https://api.avax.network/ext/bc/C/rpcc',
  }
}
if (FORK_FUJI) {
  forkingData = {
    url: 'https://api.avax-test.network/ext/bc/C/rpc',
  }
}

//...
```

Next, we must add the Avalanche chains to our Hardhat configuration by adding the following code after the previously added code snippet.

```js
// ...

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    hardhat: {
      gasPrice: 225000000000,
      chainId: !forkingData ? 43112 : undefined, //Only specify a chainId if we are not forking
      forking: forkingData
    },
    fuji: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43113,
      accounts: [
        // YOUR PRIVATE KEY HERE
      ]
    },
    mainnet: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43114,
      accounts: [
        // YOUR PRIVATE KEY HERE
      ]
    }
  }
}
```

Once the configuration is set up correctly, we can start testing our smart contracts on a local network forking data from Mainnet, or on the Fuji test network. This will allow us to ensure that everything is working as expected and that our contracts are functioning correctly.

> To learn more about forking the Mainnet on Harhdat, and gaining access to all the smart contracts on it, visit [https://hardhat.org/guides/mainnet-forking.html](https://hardhat.org/guides/mainnet-forking.html).

Your `hardhat.config.js` file should be looking something like this:

```js

require("@nomicfoundation/hardhat-toolbox");

const FORK_FUJI = false;
const FORK_MAINNET = false;
let forkingData = undefined;

if (FORK_MAINNET) {
  forkingData = {
    url: "https://api.avax.network/ext/bc/C/rpcc",
  };
}
if (FORK_FUJI) {
  forkingData = {
    url: "https://api.avax-test.network/ext/bc/C/rpc",
  };
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    hardhat: {
      gasPrice: 225000000000,
      chainId: !forkingData ? 43112 : undefined, //Only specify a chainId if we are not forking
      forking: forkingData
    },
    fuji: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43113,
      accounts: [
        // YOUR PRIVATE KEY HERE
      ]
    },
    mainnet: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43114,
      accounts: [
         "YOUR PRIVATE KEY HERE"
      ]
    }
  }
}

```

## Verify
One additional step is to verify the deployed smart contract, [to do this we need an API Key from Snowtrace, you need to provide an email address to complete this step, but is straightforward](https://snowtrace.io/register).

Once you have your account set up, you can go to [your API Keys section](https://snowtrace.io/myapikey) and create a key from there.

Once you have your new API key, we can paste it into our Harhat config file, like so:

```js
module.exports = {
  // ...rest of the config...
  etherscan: {
    apiKey: "Your API key here",
  },
};
```
Now we have access to the *verify* task, which allows us to verify smart contracts on specific networks.

```bash
$ npx hardhat verify <contract address> <arguments> --network <network>
```

## Scripts
We need 1 script, the `deploy.js` script, to deploy our Points token smart contract to the chain that we want.

### Deploy script(deploy.js)
```js
const hre = require("hardhat");

async function main() {
  // Get the DegenTokens smart contract
  const Degen = await hre.ethers.getContractFactory("DegenToken");

  // Deploy it
  const degen = await Degen.deploy();
  await degen.waitForDeployment();

  // Display the contract address
  console.log(`Degen token deployed to ${degen.target}`);
}

// Hardhat recommends this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Once we are satisfied with the results of our testing on the Fuji test network, we can proceed with deploying our smart contracts to Avalanche's Mainnet. This will require us to modify the configuration file once again to point to the appropriate endpoint for the Mainnet.

In conclusion, configuring Harhat to work with Avalanche by default involves adding Avalanche to its supported chains and specifying the Fuji test network as the default network for testing. Once testing is complete, we can deploy our smart contracts to Avalanche's Mainnet.

## Deploying
Now we need to deploy our smart contract, first, we are going to deploy our Token to testnet, we first need to get some Testnet AVAX from the Faucet, so we will get that first go to [https://faucet.avax.network/](https://faucet.avax.network/).

I'm going to assume that you have a wallet setup on your browser, we now need to connect to the Fuji Testnet, and you need to add the network to your wallet, here is all the information that a wallet like Metamask requires you to connect to a chain.

    *Network Name*: Avalanche Fuji C-Chain
    *New RPC URL*: https://api.avax-test.network/ext/bc/C/rpc
    *ChainID*: 43113
    *Symbol*: AVAX
    *Explorer*: https://testnet.snowtrace.io/

> There is a quick way to connect to the Fuji (C-Chain), there is a `🦊 Add Subnet to Metamask` button, below the main modal in the faucet, if you press it, it will automate the process of adding the network to your wallet.

Once we have this setup, we can get our testnet tokens, be sure that the `Select Network` dropdown is `Fuji (C-Chain)` and that the `Select Token` dropdown is set to `AVAX (Native)`.

Now you can connect your wallet using the `🦊 Connect` button, or you can paste your address directly, remember these are test tokens and have no value but you can only request a few tokens per day. Once all of that is complete, you can request AVAX, it takes a few seconds to be available in your wallet which is fantastic.

Before deploying the smart contract we need to install one more thing, the hardhat toolbox

```bash
$ npm install --save-dev @nomicfoundation/hardhat-toolbox
```
Now that we have test tokens we are going to deploy the token to the Fuji (C-Chain) test network, go to your terminal, and type:

```bash
$ npx hardhat run scripts/deploy.js --network fuji
```

> Remember to set your private key on your `hardhat.config.js` file, since Harhdat is going to search there to deploy your smart contract.

You should see something like this printout in the console:
```bash
$ npx hardhat run scripts/deploy.js --network fuji
Points token deployed to <YOUR TOKEN ADDRESS>
```

If you have set up your API key, we can verify the smart contract on Fuji by running the following command:

```bash
$ npx hardhat verify <YOUR TOKEN ADDRESS> --network fuji
```

Now we can go to [https://testnet.snowtrace.io/](https://testnet.snowtrace.io/) and search for our smart contract, using the same address that we used before, and there it is our Degen Token, with a verified contract.

(everything after this is optional)

This is great but we now need to deploy the smart contract to the mainnet, to have it in a completely secure environment.

You need real AVAX for this section, you can use Binance or Coinbase to buy AVAX and transfer it to your wallet address, the same wallet address that you defined in your `hardhat.config.js`, once you have your wallet funded you can run:

```bash
$ npx hardhat run scripts/deploy.js --network mainnet
$ npx hardhat verify <YOUR TOKEN ADDRESS> --network mainnet
```

This will deploy and verify your smart contract, now it's available on Avalanche Mainnet (C-Chain)!!!

After you have verified your smart contract on the testnet, now you can use remix IDE to interact with the smart contract
open Remix.ethereum.org and set the environment as inject provider, it will ask you to link it with a wallet, choose metamask.

Make sure you have the same wallet address where you recieved the tesnet Avax tokens. And it should be in Fuji C chain network. After you have successfully connected your metamask wallet with the Remix IDE, you copy the address and use it to load the smart contract in the deployed section of the webpage. If it's not happening then just copy and paste the smart contract code and then try it again, it will happen by now. 
once you have your smart contract loaded up, you can now interact with the smart contract, make transactions, at every transaction it will ask you to approve it on metamask wallet and then you can view it on snowtrace avalanche testnet explorer. You can just click on the popup from Metamask where it shows transaction confirmation and it will direct you to the transaction details page. 
