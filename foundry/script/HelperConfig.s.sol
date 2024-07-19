// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {EPOS} from "../src/EPOS.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    address MOCK_STORE_OWNER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address owner;
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 1) {
            activeNetworkConfig = getMainnetConfig();
        } else if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == 8453) {
            activeNetworkConfig = getBaseConfig();
        } else if (block.chainid == 84532) {
            activeNetworkConfig = getBaseSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory mainnetConfig) {
        return NetworkConfig({
            owner: 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85,
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory sepoliaConfig) {
        return NetworkConfig({
            owner: 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85,
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getBaseConfig() public pure returns (NetworkConfig memory baseConfig) {
        return NetworkConfig({
            owner: 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85,
            priceFeed: 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70
        });
    }

    function getBaseSepoliaConfig() public pure returns (NetworkConfig memory baseSepoliaConfig) {
        return NetworkConfig({
            owner: 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85,
            priceFeed: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1
        });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0) || activeNetworkConfig.owner != address(0)) {
            return activeNetworkConfig;
        }
        // 1. Deploy the mocks
        // 2. Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        return NetworkConfig({owner: MOCK_STORE_OWNER, priceFeed: address(mockPriceFeed)});
    }
}
