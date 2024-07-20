import { PublicClient, WalletClient } from "viem";
import { EPOS } from "../EPOS";
import { foundry } from "viem/chains";
import { Product } from "../types";
import type { Hex } from "viem";

const addProduct = async (
  publicClient: PublicClient,
  walletClient: WalletClient,
  product: Product,
) => {
  let transactionHash: Hex = "0x";
  try {
    const { request } = await publicClient.simulateContract({
      account: EPOS.owner,
      chain: foundry,
      address: EPOS.address,
      abi: EPOS.abi,
      functionName: "addProduct",
      args: [BigInt(product.id), BigInt(product.price), BigInt(product.stock)],
    });
    transactionHash = await walletClient.writeContract(request);
  } catch (error) {
    throw new Error("Could add product.");
  } finally {
    console.log(`Transaction Successful: ${transactionHash}`);
  }
};

export { addProduct };
