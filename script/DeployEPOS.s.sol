// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {EPOS} from "../src/EPOS.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployEPOS is Script {
    function run() public returns (EPOS epos) {
        HelperConfig helperConfig = new HelperConfig();
        (address owner, address priceFeed) = helperConfig.activeNetworkConfig();

        vm.broadcast();
        EPOS deployedEPOS = new EPOS(owner, priceFeed);
        return deployedEPOS;
    }
}
