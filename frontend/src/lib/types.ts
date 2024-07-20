import { Address, PublicClient, WalletClient, Abi } from "viem";

// Type for on-chain product data
type OnChainProduct = {
  id: bigint;
  price: bigint;
  stock: bigint;
};

// Type for complete product including off-chain data
type Product = {
  id: number;
  price: number;
  stock: number;
  name?: string;
  description?: string;
  image?: string;
};

// Type for product data stored off-chain
type ProductData = {
  [key: string]: {
    name: string;
    description: string;
    image: string;
  };
};

type EPOSConfig = {
  address: Address;
  owner: Address;
  abi: Abi;
  getProductCount: (client: PublicClient) => Promise<number>;
  getProduct: (client: PublicClient, id: number) => Promise<OnChainProduct>;
  productActive: (client: PublicClient, id: number) => Promise<boolean>;
  getProducts: (client: PublicClient) => Promise<[number, OnChainProduct][]>;
  addProduct: (
    publicClient: PublicClient,
    walletClient: WalletClient,
    product: Product,
  ) => Promise<void>;
};

export type { Product, OnChainProduct, ProductData, EPOSConfig };
