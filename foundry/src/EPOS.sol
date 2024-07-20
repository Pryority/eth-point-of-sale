// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error ERR_UNEQUAL_LENGTH();
error ERR_NO_FUNDS_TO_WITHDRAW();
error ERR_PRODUCT_INACTIVE();
error ERR_INSUFFICIENT_ETHER();
error ERR_INSUFFICIENT_STOCK();
error ERR_PRODUCT_ACTIVE();
error ERR_PRODUCTS_REQUIRED();
error ERR_ONLY_STORE_OWNER();
error ERR_SALE_NONEXISTENT();
error ERR_SALE_COMPLETED();

// •⁄⁄••⁄⁄••⁄⁄••⁄⁄••⁄⁄•
// |    E  P  O  S    |
// •⁄⁄••⁄⁄••⁄⁄••⁄⁄••⁄⁄•
contract EPOS {
    using PriceConverter for uint256;

    AggregatorV3Interface private s_priceFeed;
    address private s_owner;
    uint256 private s_productCount;
    uint256 private s_saleCount;
    uint256 private s_totalRevenue;
    uint256 private s_saleIds;
    mapping(uint256 => Product) private s_products;
    mapping(uint256 => Sale) private s_sales;
    mapping(uint256 => bool) private s_productActive;
    mapping(uint256 => bool) private s_saleCompleted;

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
        require(msg.sender == s_owner, ERR_ONLY_STORE_OWNER());
        _;
    }

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

    // Maybe create a function that creates a commitment of a payment...
    // The clerk checking out the customer creates the commitment, the customer provides the commitment during payment by scanning a QR or something.
    // function createCommitment() public view returns (bytes32 commitment) {}
    modifier activeProduct(uint256 _productId) {
        require(s_productActive[_productId], ERR_PRODUCT_INACTIVE());
        _;
    }

    modifier inactiveProduct(uint256 _productId) {
        require(!s_productActive[_productId], ERR_PRODUCT_ACTIVE());
        _;
    }

    modifier equal(uint256[] memory _productIds, uint256[] memory _quantities) {
        require(_productIds.length == _quantities.length, ERR_UNEQUAL_LENGTH());
        _;
    }

    modifier completed(uint256 _saleId) {
        require(s_saleCompleted[_saleId], ERR_SALE_NONEXISTENT());
        _;
    }

    function addProduct(
        uint256 _id,
        uint256 _price,
        uint256 _stock
    ) public onlyOwner inactiveProduct(_id) {
        s_products[_id] = Product(_price, _stock);
        s_productActive[_id] = true;
        s_productCount++;
    }

    function updateProduct(
        uint256 _id,
        uint256 _price,
        uint256 _stock
    ) public onlyOwner activeProduct(_id) {
        s_products[_id] = Product(_price, _stock);
    }

    function processPayment(
        uint256[] memory _productIds,
        uint256[] memory _quantities
    ) public payable equal(_productIds, _quantities) {
        require(_productIds.length != 0, ERR_PRODUCTS_REQUIRED());
        require(!s_saleCompleted[s_saleCount], ERR_SALE_COMPLETED());

        uint256 totalAmountInEth = 0;
        uint256 totalAmountInCurrency = 0;
        SaleItem[] memory saleProducts = new SaleItem[](_productIds.length);

        for (uint256 i = 0; i < _productIds.length; i++) {
            uint256 productId = _productIds[i];
            uint256 quantity = _quantities[i];
            Product memory product = getProduct(productId);

            require(product.stock > quantity, ERR_INSUFFICIENT_STOCK());

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

        require(msg.value >= totalAmountInEth, ERR_INSUFFICIENT_ETHER());

        s_saleCount++;
        s_sales[s_saleCount] = Sale(
            block.timestamp,
            totalAmountInEth,
            saleProducts
        );

        s_totalRevenue += totalAmountInEth;

        if (msg.value > totalAmountInEth) {
            payable(msg.sender).transfer(msg.value - totalAmountInEth);
        }

        s_saleCompleted[s_saleCount] = true;
        emit SaleCompleted(
            s_saleCount,
            totalAmountInEth,
            totalAmountInCurrency
        );
    }

    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, ERR_NO_FUNDS_TO_WITHDRAW());
        payable(s_owner).transfer(balance);
    }

    // VIEW FUNCTIONS --
    function getProduct(
        uint256 _productId
    ) public view activeProduct(_productId) returns (Product memory product) {
        return s_products[_productId];
    }

    function getSale(
        uint256 _saleId
    ) public view completed(_saleId) returns (Sale memory sale) {
        return s_sales[_saleId];
    }

    function getOwner() public view returns (address owner) {
        return s_owner;
    }

    function getProductCount() public view returns (uint256 count) {
        return s_productCount;
    }

    function productActive(uint256 _productId) public view returns (bool yes) {
        return s_productActive[_productId];
    }

    function getPriceFeedAddress() public view returns (address priceFeed) {
        return address(s_priceFeed);
    }
}
