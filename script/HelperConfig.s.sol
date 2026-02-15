// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract CodeConstants {
    /*VRF mock values */
    uint96 public constant MOCK_BASE_FEE = 0.25 ether;
    uint96 public constant MOCK_GAS_PRICE_LINK = 1e9;
    int256 public constant MOCK_WEI_PER_UINT_LINK = 4e15; //  LINK/ETH price

    /*chain ids */
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        // Requirement - base structure
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        uint256 subscriptionId;
        address link; // token contract of link(for funding)
        address account;
    }

    NetworkConfig public localNetworkConfig; // local state variable of type NetworkConfig
    mapping(uint256 chainId => NetworkConfig) public networkConfigs; //mapping (chainId => NetWorkConfig)

    constructor() {
        // Don't initialize here - will be loaded lazily from env vars when needed
    }

    function getConfigByChainId(
        //gets config function bt passing the chainid
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (chainId == ETH_SEPOLIA_CHAIN_ID) {
            // Load Sepolia config from env vars (lazy initialization)
            if (networkConfigs[chainId].vrfCoordinator == address(0)) {
                networkConfigs[chainId] = getSepoliaEthConfig();
            }
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            // else deploy or get the already deployed mock, and its network config
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getConfig() public returns (NetworkConfig memory) {
        // get thr config w.r.t. chain contract deployed on
        return getConfigByChainId(block.chainid);
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        // pre-defined sepolia config
        // Read sensitive values from environment variables
        uint256 subscriptionId = vm.envOr("VRF_SUBSCRIPTION_ID", uint256(0));
        address account = vm.envOr("DEPLOYER_ACCOUNT", address(0));

        // Validate that required environment variables are set
        require(
            subscriptionId != 0,
            "HelperConfig: VRF_SUBSCRIPTION_ID not set in .env"
        );
        require(
            account != address(0),
            "HelperConfig: DEPLOYER_ACCOUNT not set in .env"
        );

        return
            NetworkConfig({
                entranceFee: .01 ether, // 0.01 ETH
                interval: 30, //30 seconds
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                callbackGasLimit: 500000,
                subscriptionId: subscriptionId,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789, // link token contract
                account: account
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // deploy or get the mock
        // check to see if we set an active network conifg
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }

        //deploy a mocks
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock( //takes baseFee, gasPrice, weiPerUnitLink as params
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UINT_LINK
        );
        LinkToken linkToken = new LinkToken(); // deploying link contract for the chainlink vrf mock

        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({ // pre-defined NetworkConfig for the anvil
            entranceFee: 0.01 ether,
            interval: 30, //30 seconds
            vrfCoordinator: address(vrfCoordinatorMock),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, //doesn't matter on mock!
            callbackGasLimit: 500000,
            subscriptionId: 0,
            link: address(linkToken),
            account: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38 // Base.sol - foundry uses this default account
        });
        return localNetworkConfig;
    }
}
