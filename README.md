## ETH Point of Sale

**Add Items to Your E-Store and Process Payments.**


Take JSON data and parse it using Foundry:

```json
{
  "items": [
    {
      "id": 1,
      "price": 100,
      "stock": 50
    },
    {
      "id": 2,
      "price": 200,
      "stock": 30
    }
  ],
  "saleItems": [
    {
      "saleItemId": 1,
      "quantity": 2,
      "itemId": 1,
      "pricePerUnit": 100,
      "totalPrice": 200
    },
    {
      "saleItemId": 2,
      "quantity": 1,
      "itemId": 2,
      "pricePerUnit": 200,
      "totalPrice": 200
    }
  ],

  ...

}
```

```solidity
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
```

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
