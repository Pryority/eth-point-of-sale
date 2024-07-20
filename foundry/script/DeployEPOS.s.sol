// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {EPOS} from "../src/EPOS.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Seed} from "./Seed.s.sol";

contract DeployEPOS is Script {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    function run() public returns (EPOS epos) {
        HelperConfig helperConfig = new HelperConfig();
        Seed seed = new Seed();
        (, address priceFeed) = helperConfig.activeNetworkConfig();
        (bytes memory seedProducts, , ) = seed.getData();
        EPOS.Product[] memory initialProducts = abi.decode(
            seedProducts,
            (EPOS.Product[])
        );

        vm.broadcast(deployerPrivateKey);
        EPOS deployedEPOS = new EPOS(priceFeed, initialProducts);

        return deployedEPOS;
    }
}
