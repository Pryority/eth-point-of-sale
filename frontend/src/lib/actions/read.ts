import type { PublicClient } from "viem";
import { EPOS } from "../EPOS";
import type { OnChainProduct } from "../types";

const getProductCount = async (client: PublicClient) => {
  return Number(
    (await client.readContract({
      address: EPOS.address,
      abi: EPOS.abi,
      functionName: "getProductCount",
    })) as bigint,
  ) as number;
};

const getProduct = async (client: PublicClient, id: number) => {
  const product = (await client.readContract({
    address: EPOS.address,
    abi: EPOS.abi,
    functionName: "getProduct",
    args: [BigInt(id)],
  })) as OnChainProduct;

  return product;
};

const productActive = async (client: PublicClient, id: number) => {
  const isActive = (await client.readContract({
    address: EPOS.address,
    abi: EPOS.abi,
    functionName: "productActive",
    args: [BigInt(id)],
  })) as boolean;

  return isActive;
};

const getProducts = async (
  client: PublicClient,
): Promise<[number, OnChainProduct][]> => {
  const productCount = await getProductCount(client);
  const products: [number, OnChainProduct][] = [];

  for (let id = 1; id <= productCount; id++) {
    try {
      const product = await getProduct(client, id);
      const isActive = await productActive(client, id);
      if (isActive) {
        products.push([id, product]);
      }
    } catch (error) {
      console.error(`Error fetching product ${id}:`, error);
    }
  }

  return products;
};

export { getProductCount, getProduct, productActive, getProducts };
