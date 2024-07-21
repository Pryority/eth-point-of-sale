// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {Store} from "./Store.sol";

// •⁄⁄••⁄⁄••⁄⁄••⁄⁄••⁄⁄•
// |    E  P  O  S    |
// •⁄⁄••⁄⁄••⁄⁄••⁄⁄••⁄⁄•
/// @author ETH Point of Sale
/// @title The Simple Onchain Store System
/// @title EPOS (Electronic Point of Sale) Contract
/// @author Matthew Pryor
/// @notice This contract enables easy-to-use Ethereum stores
/// @dev All function calls are currently implemented without side effects
contract EPOS {
    using PriceConverter for uint256;

    // State variables
    AggregatorV3Interface private immutable s_priceFeed;
    address private immutable s_owner;
    uint256 private s_productCount;
    uint256 private s_saleCount;
    uint256 private s_totalRevenue;
    uint256 private s_saleIds;

    mapping(uint256 => Store.Product) private s_products;
    mapping(uint256 => Store.Sale) private s_sales;
    mapping(uint256 => bool) private s_productActive;
    mapping(uint256 => bool) private s_saleCompleted;

    // Events
    event SaleCompleted(
        uint256 indexed saleId,
        uint256 totalAmountInEth,
        uint256 totalAmountInCurrency
    );

    // Errors
    error ERR_SALE__UNEQUAL_LENGTH();
    error ERR_SALE__NONEXISTENT();
    error ERR_SALE__COMPLETED();
    error ERR_PAYMENT__NO_FUNDS_TO_WITHDRAW();
    error ERR_PAYMENT__INSUFFICIENT_ETHER();
    error ERR_PAYMENT__QUANTITY_REQUIRED();
    error ERR_PRODUCT__PRODUCT_INACTIVE();
    error ERR_PRODUCT__PRODUCT_ACTIVE();
    error ERR_PRODUCT__INSUFFICIENT_STOCK();
    error ERR_AUTH__ONLY_STORE_OWNER();

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != s_owner) revert ERR_AUTH__ONLY_STORE_OWNER();
        _;
    }

    modifier activeProduct(uint256 _productId) {
        if (!s_productActive[_productId]) revert ERR_PRODUCT__PRODUCT_INACTIVE();
        _;
    }

    modifier inactiveProduct(uint256 _productId) {
        if (s_productActive[_productId]) revert ERR_PRODUCT__PRODUCT_ACTIVE();
        _;
    }

    modifier equal(uint256[] memory _productIds, uint256[] memory _quantities) {
        if ((_productIds.length != _quantities.length) || (_productIds.length < 0 || _quantities.length < 0)) revert ERR_SALE__UNEQUAL_LENGTH();
        _;
    }

    modifier completed(uint256 _saleId) {
        if (!s_saleCompleted[_saleId]) revert ERR_SALE__NONEXISTENT();
        _;
    }

    /// @notice Contract constructor
    /// @param _priceFeed Address of the price feed contract
    /// @param _initialProducts Array of initial products to add
    constructor(address _priceFeed, Store.Product[] memory _initialProducts) {
        s_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);

        for (uint256 i = 0; i < _initialProducts.length; i++) {
            addProduct(
                i + 1,
                _initialProducts[i].price,
                _initialProducts[i].stock
            );
        }
    }

    /// @notice Adds a new product to the store
    /// @param _id Product ID
    /// @param _price Product price
    /// @param _stock Product stock
    function addProduct(
        uint256 _id,
        uint256 _price,
        uint256 _stock
    ) public onlyOwner inactiveProduct(_id) {
        s_products[_id] = Store.Product(_price, _stock);
        s_productActive[_id] = true;
        s_productCount++;
    }

    /// @notice Updates an existing product
    /// @param _id Product ID
    /// @param _price New product price
    /// @param _stock New product stock
    function updateProduct(
        uint256 _id,
        uint256 _price,
        uint256 _stock
    ) public onlyOwner activeProduct(_id) {
        s_products[_id] = Store.Product(_price, _stock);
    }

    /// @notice Processes a payment for multiple products
    /// @param _productIds Array of product IDs
    /// @param _quantities Array of quantities for each product
    function processPayment(
        uint256[] memory _productIds,
        uint256[] memory _quantities
    ) public payable equal(_productIds, _quantities) {
        if (s_saleCompleted[s_saleCount]) revert ERR_SALE__COMPLETED();

        uint256 totalAmountInEth = 0;
        uint256 totalAmountInCurrency = 0;
        Store.SaleItem[] memory saleProducts = new Store.SaleItem[](
            _productIds.length
        );

        for (uint256 i = 0; i < _productIds.length; i++) {
            if (!s_productActive[_productIds[i]]) revert ERR_PRODUCT__PRODUCT_INACTIVE();
            if (_quantities[i] == 0) revert ERR_PAYMENT__QUANTITY_REQUIRED();
            uint256 productId = _productIds[i];
            uint256 quantity = _quantities[i];
            Store.Product memory product = getProduct(productId);

            if (product.stock <= quantity) revert ERR_PRODUCT__INSUFFICIENT_STOCK();

            uint256 productTotalInCurrency = product.price * quantity;
            uint256 productTotalInEth = productTotalInCurrency
                .getConversionRate(s_priceFeed);

            totalAmountInEth += productTotalInEth;
            totalAmountInCurrency += productTotalInCurrency;

            s_products[productId].stock -= quantity;

            saleProducts[i] = Store.SaleItem(
                i + 1,
                quantity,
                productId,
                product.price,
                productTotalInCurrency
            );
        }

        if (msg.value < totalAmountInEth) revert ERR_PAYMENT__INSUFFICIENT_ETHER();

        s_saleCount++;
        s_sales[s_saleCount] = Store.Sale(
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

    /// @notice Withdraws funds from the contract
    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert ERR_PAYMENT__NO_FUNDS_TO_WITHDRAW();
        payable(s_owner).transfer(balance);
    }

    // View Functions

    /// @notice Retrieves a product by ID
    /// @param _productId Product ID
    /// @return product The product details
    function getProduct(
        uint256 _productId
    )
        public
        view
        activeProduct(_productId)
        returns (Store.Product memory product)
    {
        return s_products[_productId];
    }

    /// @notice Retrieves a sale by ID
    /// @param _saleId Sale ID
    /// @return sale The sale details
    function getSale(
        uint256 _saleId
    ) public view completed(_saleId) returns (Store.Sale memory sale) {
        return s_sales[_saleId];
    }

    /// @notice Gets the contract owner's address
    /// @return owner The owner's address
    function getOwner() public view returns (address owner) {
        return s_owner;
    }

    /// @notice Gets the total number of products
    /// @return count The product count
    function getProductCount() public view returns (uint256 count) {
        return s_productCount;
    }

    /// @notice Checks if a product is active
    /// @param _productId Product ID
    /// @return yes True if the product is active, false otherwise
    function productActive(uint256 _productId) public view returns (bool yes) {
        return s_productActive[_productId];
    }

    /// @notice Gets the price feed contract address
    /// @return priceFeed The price feed contract address
    function getPriceFeedAddress() public view returns (address priceFeed) {
        return address(s_priceFeed);
    }
}
