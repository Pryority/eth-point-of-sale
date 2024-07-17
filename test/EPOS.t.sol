// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, stdError, console2} from "forge-std/Test.sol";
import {EPOS} from "../src/EPOS.sol";
import {DeployEPOS} from "../script/DeployEPOS.s.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract EPOSTest is Test {
    using PriceConverter for uint256;
    EPOS private i_epos;
    address private i_storeOwner;
    address private CUSTOMER = address(68089);
    bytes private seedData;

    function setUp() public {
        vm.prank(i_storeOwner);
        DeployEPOS deployEPOS = new DeployEPOS();
        i_epos = deployEPOS.run();
        i_storeOwner = i_epos.getOwner();
        (bytes memory itemsBytes, , ) = getSeedData();
        EPOS.Item[] memory items = abi.decode(itemsBytes, (EPOS.Item[]));
        vm.startPrank(i_storeOwner);
        for (uint256 i = 0; i < items.length; i++) {
            EPOS.Item memory item = items[i];
            i_epos.addItem(item.id, item.stock, item.price);
            console2.log(
                "Item ID: %d, Price: %d, Stock: %d",
                item.id,
                item.stock,
                item.price
            );
        }
        vm.stopPrank();
    }

    function test__addItem__ADD_AN_ITEM() public {
        vm.prank(i_storeOwner);
        i_epos.addItem(3, 75, 150);
        assertEq(i_epos.getItem(3).id, 3);
    }

    function test__processPayment__CHECKOUT_A_CUSTOMER() public {
        (, bytes memory saleItemsBytes, ) = getSeedData();
        EPOS.SaleItem[] memory saleItems = abi.decode(
            saleItemsBytes,
            (EPOS.SaleItem[])
        );
        uint256[] memory saleItemIds = new uint256[](saleItems.length);
        uint256[] memory quantities = new uint256[](saleItems.length);

        uint256 totalAmountInEth = 0;

        for (uint256 i = 0; i < saleItems.length; i++) {
            EPOS.SaleItem memory item = saleItems[i];
            uint256 saleItemId = item.saleItemId;
            uint256 quantity = item.quantity;
            uint256 itemId = item.itemId;
            uint256 pricePerUnit = item.pricePerUnit;
            uint256 totalPrice = item.totalPrice;
            uint256 itemTotalInCurrency = i_epos
                .getItem(item.saleItemId)
                .price * quantity;
            uint256 itemTotalInEth = itemTotalInCurrency.getConversionRate(
                AggregatorV3Interface(i_epos.getPriceFeedAddress())
            );

            saleItemIds[i] = saleItems[i].saleItemId;
            quantities[i] = saleItems[i].quantity;
            totalAmountInEth += itemTotalInEth;

            console2.log(
                "SaleItem %d -- Quantity: %d, Item ID: %d",
                saleItemId,
                quantity,
                itemId
            );
            console2.log(
                "------------- Price Per Unit: %d, Total Price: %d",
                pricePerUnit,
                totalPrice
            );
        }

        hoax(CUSTOMER, totalAmountInEth);
        i_epos.processPayment{value: totalAmountInEth}(saleItemIds, quantities);
    }

    function getSeedData()
        public
        view
        returns (bytes memory, bytes memory, bytes memory)
    {
        string memory root = vm.projectRoot();
        string memory path = string.concat(
            root,
            "/test/fixtures/seedData.json"
        );
        string memory json = vm.readFile(path);

        bytes memory items = vm.parseJson(json, ".items");
        bytes memory saleItems = vm.parseJson(json, ".saleItems");
        bytes memory sales = vm.parseJson(json, ".sales");
        return (items, saleItems, sales);
    }
}
