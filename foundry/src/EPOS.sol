// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error UnequalQuantitiesAndProducts();
error InvalidProductID();
error InvalidSaleID();
error DuplicateID();
error InvalidCurrency();
error InsufficientStock();
error InsufficientPayment();
error NoFundsToWithdraw();
error NoProductsToPurchase();

contract EPOS {
    using PriceConverter for uint256;

    AggregatorV3Interface private s_priceFeed;
    address private s_owner;
    uint256 private s_nextProductId;
    uint256 private s_currentSaleID;
    uint256 private s_totalRevenue;
    mapping(uint256 => Product) private s_products;
    mapping(uint256 => Sale) private s_sales;

    struct Product {
        uint256 id;
        uint256 stock;
        uint256 price;
    }

    struct SaleItem {
        uint256 saleProductId;
        uint256 quantity;
        uint256 productId;
        uint256 pricePerUnit;
        uint256 totalPrice;
    }

    struct Sale {
        uint256 saleId;
        uint256 timestamp;
        uint256 totalAmount;
        SaleItem[] products;
    }

    struct Currency {
        uint256 id;
        AggregatorV3Interface priceFeed;
    }

    event SaleCompleted(
        uint256 indexed saleId,
        uint256 totalAmountInEth,
        uint256 totalAmountInCurrency
    );

    modifier onlyOwner() {
        require(msg.sender == s_owner, "Only the owner can call this");
        _;
    }

    constructor(
        address _owner,
        address _priceFeed,
        Product[] memory _initialProducts
    ) {
        s_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
        s_nextProductId = 1;

        // Add initial products if provided
        if (_initialProducts.length > 0) {
            for (uint256 i = 0; i < _initialProducts.length; i++) {
                Product memory product = _initialProducts[i];
                addProduct(product.id, product.price, product.stock);
            }
        }

        s_owner = _owner;
    }

    // Maybe create a function that creates a commitment of a payment...
    // The clerk checking out the customer creates the commitment, the customer provides the commitment during payment by scanning a QR or something.
    // function createCommitment() public view returns (bytes32 commitment) {}

    function addProduct(
        uint256 _id,
        uint256 _price,
        uint256 _stock
    ) public onlyOwner {
        if (s_products[s_nextProductId].id != 0) {
            revert DuplicateID();
        }
        s_products[_id] = Product(_id, _price, _stock);
        s_nextProductId++;
    }

    function processPayment(
        uint256[] memory _productIds,
        uint256[] memory _quantities
    ) public payable {
        if (_productIds.length != _quantities.length) {
            revert UnequalQuantitiesAndProducts();
        }
        if (_productIds.length == 0) {
            revert NoProductsToPurchase();
        }

        uint256 totalAmountInEth = 0;
        uint256 totalAmountInCurrency = 0;
        SaleItem[] memory saleProducts = new SaleItem[](_productIds.length);

        for (uint256 i = 0; i < _productIds.length; i++) {
            uint256 productId = _productIds[i];
            uint256 quantity = _quantities[i];
            Product memory product = getProduct(productId);

            if (product.stock < quantity) {
                revert InsufficientStock();
            }

            uint256 productTotalInCurrency = product.price * quantity;
            uint256 productTotalInEth = productTotalInCurrency
                .getConversionRate(s_priceFeed);

            totalAmountInEth += productTotalInEth;
            totalAmountInCurrency += productTotalInCurrency;

            // Update product stock
            s_products[productId].stock -= quantity;

            saleProducts[i] = SaleItem(
                i + 1, // saleProductId (just a sequential number)
                quantity,
                productId,
                product.price,
                productTotalInCurrency
            );
        }

        if (msg.value < totalAmountInEth) {
            revert InsufficientPayment();
        }

        s_currentSaleID++;
        s_sales[s_currentSaleID] = Sale(
            s_currentSaleID,
            block.timestamp,
            totalAmountInEth,
            saleProducts
        );

        s_totalRevenue += totalAmountInEth;

        if (msg.value > totalAmountInEth) {
            payable(msg.sender).transfer(msg.value - totalAmountInEth);
        }

        emit SaleCompleted(
            s_currentSaleID,
            totalAmountInEth,
            totalAmountInCurrency
        );
    }

    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, NoFundsToWithdraw());
        payable(s_owner).transfer(balance);
    }

    /**
     * - V   I   E   W     F   U   N   C   T   I   O   N   S  -
     */
    function getOwner() public view returns (address owner) {
        return s_owner;
    }

    function getProductCount() public view returns (uint256 count) {
        return s_nextProductId;
    }

    function getProduct(
        uint256 _productId
    ) public view returns (Product memory product) {
        return s_products[_productId];
    }

    function getSale(uint256 _saleId) public view returns (Sale memory sale) {
        require(_saleId <= s_currentSaleID && _saleId > 0, InvalidSaleID());
        return s_sales[_saleId];
    }

    function getPriceFeedAddress() public view returns (address priceFeed) {
        return address(s_priceFeed);
    }
}
