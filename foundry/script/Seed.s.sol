// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

contract Seed is Script {
    function getData() public view returns (bytes memory, bytes memory, bytes memory) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/seed.json");
        string memory json = vm.readFile(path);

        bytes memory products = vm.parseJson(json, ".products");
        bytes memory saleItem = vm.parseJson(json, ".saleItems");
        bytes memory sales = vm.parseJson(json, ".sales");
        return (products, saleItem, sales);
    }
}
