#  Raffle Smart Contract with Verfiable Random Function(VRF)

A decentralized, provably fair raffle (lottery) smart contract built with **Solidity**, **Foundry**, and **Chainlink VRF v2.5**. This contract allows users to enter a raffle by paying ETH and randomly selects a winner using Chainlink's Verifiable Random Function for provably fair randomness.

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [How It Works](#how-it-works)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Testing](#testing)
- [Deployment](#deployment)
- [Security Considerations](#security-considerations)
- [License](#license)

## 🎯 About

This project implements a decentralized raffle system where:
1. Users can enter the raffle by paying a ticket fee (ETH)
2. The ticket fees accumulate to form the prize pool
3. After a specified time interval, a winner is automatically selected
4. Chainlink VRF v2.5 generates a provably random number to select the winner
5. The entire prize pool is automatically transferred to the winner
6. The raffle resets and opens for the next round

## ✨ Features

- **Permissionless Entry**: Anyone can enter the raffle by paying the entrance fee
- **Provably Fair Randomness**: Uses Chainlink VRF v2.5 for verifiable, tamper-proof random number generation
- **Automatic Winner Selection**: Chainlink Automation (or manual trigger) picks winners at regular intervals
- **Secure ETH Payout**: Winner receives the entire prize pool automatically
- **Gas-Optimized**: Built with efficient Solidity patterns and immutable variables
- **Comprehensive Testing**: Full test coverage using Foundry
- **Multi-Network Support**: Works on Sepolia testnet and local Anvil networks

## 🔄 How It Works

### Raffle Flow

1. **Entry Phase**: Users call `enterRaffle()` with ETH (≥ entrance fee)
   - Contract validates the payment and raffle state
   - Player address is added to the players array
   - `RaffleEntered` event is emitted

2. **Upkeep Check**: Chainlink Automation (or manual call) checks if upkeep is needed:
   - Time interval has passed since last winner
   - Raffle is in `OPEN` state
   - Contract has ETH balance
   - At least one player has entered

3. **Winner Selection**:
   - Contract requests random number from Chainlink VRF
   - Raffle state changes to `CALCULATING`
   - `RequestedRaffleWinner` event is emitted

4. **Randomness Fulfillment**:
   - Chainlink VRF calls back `fulfillRandomWords()`
   - Winner is selected using modulo operation on random number
   - `WinnerPikced` event is emitted

5. **Payout & Reset**:
   - Entire contract balance is sent to winner
   - Players array is reset
   - Raffle state returns to `OPEN`
   - Timestamp is updated

### Contract States

- `OPEN (0)`: Raffle is accepting entries
- `CALCULATING (1)`: Winner is being selected (VRF request pending)

## 🛠 Tech Stack

- **Solidity**: `^0.8.19`
- **Foundry**: Forge, Anvil, Cast
- **Chainlink VRF v2.5**: Verifiable Random Function
- **Chainlink Automation**: Automated upkeep (optional, can be manual)
- **Forge Std**: Testing utilities

## 📁 Project Structure

```
foundry-smart-contract-lottery/
├── src/
│   └── Raffle.sol                 # Main raffle contract
├── script/
│   ├── DeployRaffle.s.sol        # Deployment script
│   ├── HelperConfig.s.sol        # Network configuration helper
│   └── Interactions.s.sol        # VRF subscription management
├── test/
│   ├── unit/
│   │   └── RaffleTest.t.sol      # Unit tests
│   ├── integration/
│   │   └── Interactions.t.sol    # Integration tests
│   └── mocks/
│       └── LinkToken.sol          # Mock LINK token for testing
├── lib/
│   └── forge-std/                 # Default Foundry library (included in repo)
│   # Note: Other dependencies (chainlink-brownie-contracts, 
│   # foundry-devops, solmate) are not tracked in git
├── foundry.toml                   # Foundry configuration
├── Makefile                       # Build automation
├── .gitignore                     # Git ignore rules
└── README.md                      # This file
```

### What's Ignored in Git

The following are excluded from version control (see `.gitignore`):
- `cache/` - Compiler cache
- `out/` - Build artifacts
- `lib/chainlink-brownie-contracts/` - Chainlink contracts (install via `forge install`)
- `lib/foundry-devops/` - DevOps utilities (install via `forge install`)
- `lib/solmate/` - Solmate library (install via `forge install`)
- `broadcast/` - Deployment logs (except testnet/mainnet)
- `.env` - Environment variables with secrets

## 📦 Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Node.js and npm (for some tooling)
- A wallet with ETH (for testnet deployment)
- Chainlink VRF subscription (for testnet/mainnet)

## 🚀 Installation

1. **Clone the repository** (if applicable):
```bash
git clone https://github.com/PrinceTitiya/Foundry-Lottery-SC.git
cd foundry-Lottery-SC
```

2. **Install dependencies**:
   
   ⚠️ **Important**: This repository only includes `forge-std` (default Foundry library). You must install the other dependencies before building.

   Install all required dependencies:
```bash
make install
```

Or manually:
```bash
forge install cyfrin/foundry-devops@0.2.2
forge install smartcontractkit/chainlink-brownie-contracts@1.1.1
forge install foundry-rs/forge-std@v1.8.2
forge install transmissions11/solmate@v6
```

   **Note**: The following dependencies are not tracked in git and must be installed:
   - `chainlink-brownie-contracts` - Chainlink VRF contracts
   - `foundry-devops` - DevOps utilities
   - `solmate` - Gas-optimized Solidity libraries
   - `forge-std` - Already included (default Foundry library)

3. **Build the project**:
```bash
make build
# or
forge build
```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the root directory with the following variables:

**Required for Sepolia Deployment:**
```bash
# RPC URL for Sepolia testnet
SEPOLIA_RPC_URL=<your-sepolia-rpc-url>

# Your deployer account private key (without 0x prefix)
PRIVATE_KEY=<your-private-key>

# Etherscan API key for contract verification
ETHERSCAN_API_KEY=<your-etherscan-api-key>

# Chainlink VRF Subscription ID (get from https://vrf.chain.link/)
VRF_SUBSCRIPTION_ID=<your-vrf-subscription-id>

# Deployer account address (must match PRIVATE_KEY)
DEPLOYER_ACCOUNT=<your-deployer-address>
```

**Example `.env` file:**
```bash
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
PRIVATE_KEY=your_private_key_here_without_0x
ETHERSCAN_API_KEY=your_etherscan_api_key
VRF_SUBSCRIPTION_ID=
DEPLOYER_ACCOUNT=
```

⚠️ **Security Note**: Never commit your `.env` file to version control. It's already included in `.gitignore`.

### Network Configuration

The `HelperConfig.s.sol` contract handles network-specific configurations:

- **Sepolia Testnet**: Pre-configured with Chainlink VRF v2.5 addresses
- **Local Anvil**: Automatically deploys mocks for testing

**Important**: The `subscriptionId` and `account` are now read from environment variables for security. Set them in your `.env` file as `VRF_SUBSCRIPTION_ID` and `DEPLOYER_ACCOUNT`.

The network configuration is handled automatically by `HelperConfig.s.sol`:
- **Sepolia**: Reads sensitive values from environment variables
- **Local Anvil**: Uses default mock values (no env vars needed)

## 💻 Usage

### Local Development

1. **Start Anvil** (local blockchain):
```bash
anvil
```

2. **Run tests**:
```bash
make test
# or
forge test
```

3. **Deploy locally**:
```bash
forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url http://localhost:8545 --broadcast
```

### Interacting with the Contract

#### Enter Raffle
```solidity
raffle.enterRaffle{value: entranceFee}();
```

#### Check Upkeep
```solidity
(bool upkeepNeeded, ) = raffle.checkUpkeep("");
```

#### Perform Upkeep (Manual)
```solidity
raffle.performUpkeep("");
```

#### Get Contract State
```solidity
uint256 entranceFee = raffle.getEntranceFee();
Raffle.RaffleState state = raffle.getRaffleState();
address winner = raffle.getRecentWinner();
```

## 🧪 Testing

Run all tests:
```bash
make test
```

Run with verbosity:
```bash
forge test -vvv
```

Run specific test:
```bash
forge test --match-test testEnterRaffle
```

### Test Coverage

The test suite includes:
- ✅ Entry validation (insufficient payment, wrong state)
- ✅ Upkeep conditions (time, balance, players, state)
- ✅ Winner selection and payout
- ✅ State transitions
- ✅ Event emissions
- ✅ Reentrancy protection

## 🚢 Deployment

### Deploy to Sepolia Testnet

1. **Set up Chainlink VRF Subscription**:
   - Create a subscription on [Chainlink VRF](https://vrf.chain.link/)
   - Fund it with LINK tokens
   - Note your subscription ID

2. **Configure Environment Variables**:
   - Create a `.env` file in the root directory
   - Add all required variables (see [Configuration](#-configuration) section):
     - `SEPOLIA_RPC_URL`
     - `PRIVATE_KEY`
     - `ETHERSCAN_API_KEY`
     - `VRF_SUBSCRIPTION_ID` (from step 1)
     - `DEPLOYER_ACCOUNT` (address matching your PRIVATE_KEY)

3. **Deploy**:
```bash
make deploy-sepolia
```

Or manually:
```bash
forge script script/DeployRaffle.s.sol:DeployRaffle \
  --rpc-url $SEPOLIA_RPC_URL \
  --account mywallet \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  -vvvv
```

4. **Add Consumer** (if not done automatically):
   - Add your deployed contract address to the VRF subscription as a consumer

5. **Set up Chainlink Automation** (optional):
   - Register your contract with Chainlink Automation
   - Set the `checkUpkeep` and `performUpkeep` functions

## 🔒 Security Considerations

### Implemented Security Features

- ✅ **Checks-Effects-Interactions (CEI) Pattern**: Prevents reentrancy attacks
- ✅ **Immutable Variables**: Critical parameters cannot be changed after deployment
- ✅ **State Machine**: Prevents invalid state transitions
- ✅ **Provable Randomness**: Uses Chainlink VRF instead of block variables
- ✅ **Input Validation**: Validates entrance fee and raffle state
- ✅ **Safe Transfer**: Uses low-level call with success check

### Important Security Notes

⚠️ **Never use block variables for randomness**:
- `block.timestamp`, `block.number`, `blockhash` are predictable
- Always use Chainlink VRF or similar for randomness

⚠️ **VRF is Asynchronous**:
- Randomness comes via callback
- Contract must handle pending state correctly

⚠️ **Upkeep Requirements**:
- Ensure subscription is funded with LINK
- Monitor gas limits for callback

## 📝 Contract Details

### Key Functions

- `enterRaffle()`: Enter the raffle by paying entrance fee
- `checkUpkeep(bytes)`: Check if upkeep is needed (view function)
- `performUpkeep(bytes)`: Trigger winner selection
- `fulfillRandomWords(uint256, uint256[])`: VRF callback (internal)

### Events

- `RaffleEntered(address indexed player)`: Emitted when a player enters
- `RequestedRaffleWinner(uint256 indexed requestId)`: Emitted when VRF is requested
- `WinnerPikced(address indexed winner)`: Emitted when winner is selected

### Errors

- `Raffle__SendMoreToEnterRaffle()`: Insufficient payment
- `Raffle__TransferFailed()`: ETH transfer to winner failed
- `Raffle__RaffleNotOpen()`: Attempted entry when raffle is calculating
- `Raffle__UpkeepNotNeeded(uint256, uint256, uint256)`: Upkeep conditions not met

## 📚 Additional Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Chainlink VRF Documentation](https://docs.chain.link/vrf/v2-5/getting-started)
- [Chainlink Automation Documentation](https://docs.chain.link/chainlink-automation)
- [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)

## 👤 Author

**Prince Titiya**

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🎓 Key Takeaways

- **Never use block variables for randomness** - Always use Chainlink VRF
- **VRF works asynchronously** - Design contracts with callback patterns
- **Randomness = external call** - Consider security implications
- **Raffle is an excellent learning project** - Covers many Solidity concepts

---

**⚠️ Disclaimer**: This is a learning project. Always audit smart contracts before deploying to mainnet. Use at your own risk.
