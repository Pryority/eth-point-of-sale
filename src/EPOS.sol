// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error UnequalQuantitiesAndItems();
error InvalidItemID();
error InvalidSaleID();
error DuplicateID();
error InvalidCurrency();
error InsufficientStock();
error InsufficientPayment();
error NoFundsToWithdraw();
error NoItemsToPurchase();

contract EPOS {
    using PriceConverter for uint256;
    AggregatorV3Interface private s_priceFeed;
    address private s_owner;
    uint256 private s_currentItemID;
    uint256 private s_currentSaleID;
    uint256 private s_totalRevenue;
    mapping(uint256 => Item) private s_items;
    mapping(uint256 => Sale) private s_sales;
    mapping(uint256 => Currency) private s_currencies;

    struct Item {
        uint256 id;
        uint256 stock;
        uint256 price;
    }

    struct SaleItem {
        uint256 saleItemId;
        uint256 quantity;
        uint256 itemId;
        uint256 pricePerUnit;
        uint256 totalPrice;
    }

    struct Sale {
        uint256 saleId;
        uint256 timestamp;
        uint256 totalAmount;
        SaleItem[] items;
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

    constructor(address _owner, address _priceFeed) {
        s_owner = _owner;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
        s_currentItemID = 1;
    }

    function addItem(
        uint256 _id,
        uint256 _price,
        uint256 _stock
    ) public onlyOwner {
        if (s_items[_id].id != 0) {
            revert DuplicateID();
        }
        s_items[s_currentItemID] = Item(_id, _price, _stock);
        s_currentItemID++;
    }

    function processPayment(
        uint256[] memory _itemIds,
        uint256[] memory _quantities
    ) public payable {
        if (_itemIds.length != _quantities.length) {
            revert UnequalQuantitiesAndItems();
        }
        if (_itemIds.length == 0) {
            revert NoItemsToPurchase();
        }

        uint256 totalAmountInEth = 0;
        uint256 totalAmountInCurrency = 0;
        SaleItem[] memory saleItems = new SaleItem[](_itemIds.length);

        for (uint256 i = 0; i < _itemIds.length; i++) {
            uint256 itemId = _itemIds[i];
            uint256 quantity = _quantities[i];
            Item memory item = getItem(itemId);

            if (item.stock < quantity) {
                revert InsufficientStock();
            }

            uint256 itemTotalInCurrency = item.price * quantity;
            uint256 itemTotalInEth = itemTotalInCurrency.getConversionRate(
                s_priceFeed
            );

            totalAmountInEth += itemTotalInEth;
            totalAmountInCurrency += itemTotalInCurrency;

            // Update item stock
            s_items[itemId].stock -= quantity;

            saleItems[i] = SaleItem(
                i + 1, // saleItemId (just a sequential number)
                quantity,
                itemId,
                item.price,
                itemTotalInCurrency
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
            saleItems
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
    function getItem(uint256 _itemId) public view returns (Item memory item) {
        return s_items[_itemId];
    }

    function getSale(uint256 _saleId) public view returns (Sale memory sale) {
        require(_saleId <= s_currentSaleID && _saleId > 0, InvalidSaleID());
        return s_sales[_saleId];
    }

    function getItemCount() public view returns (uint256 itemCount) {
        return s_currentItemID;
    }

    function getPriceFeedAddress() public view returns (address priceFeed) {
        return address(s_priceFeed);
    }
}
