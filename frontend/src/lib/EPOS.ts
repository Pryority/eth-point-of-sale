import { PublicClient, WalletClient, Abi } from "viem";
import { EPOSConfig, Product } from "./types";
import {
  getProduct,
  getProductCount,
  getProducts,
  productActive,
} from "./actions/read";
import { addProduct } from "./actions/write";

const FOUNDRY_MOCK_ADDRESS_1 = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";
const STORE_ADDRESS = "0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e";
import artifactJson from "../../../foundry/out/EPOS.sol/EPOS.json";
// Extract relevant information from Foundry deployment artifacts
// const address = artifactJson.address;
// console.log(address);
const abi = artifactJson.abi as Abi;
// console.log(abi);

export const EPOS: EPOSConfig = {
  address: STORE_ADDRESS, // Update each deploy
  owner: FOUNDRY_MOCK_ADDRESS_1,
  abi: abi,
  getProductCount: async (client: PublicClient) =>
    await getProductCount(client),
  getProduct: async (client: PublicClient, id: number) =>
    await getProduct(client, id),
  productActive: async (client: PublicClient, id: number) =>
    await productActive(client, id),
  getProducts: async (client: PublicClient) => await getProducts(client),
  addProduct: async (
    publicClient: PublicClient,
    walletClient: WalletClient,
    product: Product,
  ) => await addProduct(publicClient, walletClient, product),
};
