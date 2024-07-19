// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, stdError, console2} from "forge-std/Test.sol";
import {EPOS} from "../src/EPOS.sol";
import {DeployEPOS} from "../script/DeployEPOS.s.sol";
import {Seed} from "../script/Seed.s.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract EPOSTest is Test {
    using PriceConverter for uint256;

    EPOS private i_epos;
    address private i_storeOwner;
    address private CUSTOMER = address(68089);
    bytes private seedData;
    Seed private seed;

    function setUp() public {
        vm.prank(i_storeOwner);
        DeployEPOS deployEPOS = new DeployEPOS();
        seed = new Seed();
        i_epos = deployEPOS.run();
        i_storeOwner = i_epos.getOwner();
        (bytes memory productsBytes, , ) = seed.getData();
        EPOS.Product[] memory products = abi.decode(
            productsBytes,
            (EPOS.Product[])
        );
        vm.startPrank(i_storeOwner);
        for (uint256 i = 0; i < products.length; i++) {
            EPOS.Product memory product = products[i];
            i_epos.addProduct(product.id, product.stock, product.price);
            // console2.log(
            //     "Product ID: %d, Price: %d, Stock: %d",
            //     product.id,
            //     product.stock,
            //     product.price
            // );
        }
        vm.stopPrank();
    }

    function test__addProduct__ADD_AN_PRODUCT() public {
        vm.prank(i_storeOwner);
        i_epos.addProduct(3, 75, 150);
        assertEq(i_epos.getProduct(3).id, 3);
    }

    function test__processPayment__CHECKOUT_A_CUSTOMER() public {
        uint256 contractInitialBalance = address(i_epos).balance;
        console2.log("EPOS Initial Balance: %d", contractInitialBalance);
        (, bytes memory saleItemBytes, ) = seed.getData();
        EPOS.SaleItem[] memory saleItem = abi.decode(
            saleItemBytes,
            (EPOS.SaleItem[])
        );
        uint256[] memory saleProductIds = new uint256[](saleItem.length);
        uint256[] memory quantities = new uint256[](saleItem.length);

        uint256 totalAmountInEth = 0;

        for (uint256 i = 0; i < saleItem.length; i++) {
            EPOS.SaleItem memory product = saleItem[i];
            uint256 quantity = product.quantity;
            uint256 productTotalInCurrency = i_epos
                .getProduct(product.saleProductId)
                .price * quantity;
            uint256 productTotalInEth = productTotalInCurrency
                .getConversionRate(
                    AggregatorV3Interface(i_epos.getPriceFeedAddress())
                );

            saleProductIds[i] = saleItem[i].saleProductId;
            quantities[i] = saleItem[i].quantity;
            totalAmountInEth += productTotalInEth;

            // console2.log(
            //     "SaleItem %d -- Quantity: %d, Product ID: %d",
            //     saleProductId,
            //     quantity,
            //     productId
            // );
            // console2.log(
            //     "------------- Price Per Unit: %d, Total Price: %d",
            //     pricePerUnit,
            //     totalPrice
            // );
        }

        hoax(CUSTOMER, totalAmountInEth);
        uint256 customerInitialBalance = CUSTOMER.balance;
        console2.log("Customer Initial Balance: %d", customerInitialBalance);

        i_epos.processPayment{value: totalAmountInEth}(
            saleProductIds,
            quantities
        );

        uint256 customerFinalBalance = CUSTOMER.balance;
        console2.log("Customer Final Balance: %d", customerFinalBalance);
        uint256 difference = customerInitialBalance - customerFinalBalance;
        console2.log("Difference: %d", difference);

        assertEq(totalAmountInEth, difference);
        uint256 contractFinalBalance = address(i_epos).balance;
        console2.log("EPOS Final Balance: %d", contractFinalBalance);
        assertEq(
            contractFinalBalance - contractInitialBalance,
            totalAmountInEth,
            "Contract balance should increase by the payment amount"
        );
    }
}
