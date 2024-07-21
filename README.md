# ETH Point of Sale

![DEMO](./store-demo.jpeg)
![MOBILE_DEMO](./mobile-demo.png)

## Lightweight, easy to setup and use onchain store system.

A project to practice my Foundry, Viem and Vite frontend skills.

### Features

#### Store Management

1. ##### Seed Your Inventory with JSON

    ```solidity
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
    ```

2. ##### CRUD Your Products

    1. **Create**

        1. At Deployment:

            ```solidity
            constructor(address _priceFeed, Product[] memory _initialProducts) {
                    s_owner = msg.sender;
                    s_priceFeed = AggregatorV3Interface(_priceFeed);
                    s_productCount = 0;

                    // Add initial products if provided
                    for (uint256 i = 0; i < _initialProducts.length; i++) {
                        addProduct(
                            i + 1,
                            _initialProducts[i].price,
                            _initialProducts[i].stock
                        );
                    }
                }
            ```

        2. After Deployment:

            ```solidity
            function addProduct(
                uint256 _id,
                uint256 _price,
                uint256 _stock
            ) public onlyOwner inactiveProduct(_id) {
                s_products[_id] = Product(_price, _stock);
                s_productActive[_id] = true;
                s_productCount++;
            }
            ```
