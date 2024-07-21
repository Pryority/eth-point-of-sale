// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library Store {
    struct Product {
        uint256 price;
        uint256 stock;
    }

    struct SaleItem {
        uint256 saleProductId;
        uint256 quantity;
        uint256 productId;
        uint256 pricePerUnit;
        uint256 totalPrice;
    }

    struct Sale {
        uint256 timestamp;
        uint256 totalAmount;
        SaleItem[] products;
    }
}
