import { createTestClient, http, publicActions, walletActions } from "viem";
import { foundry } from "viem/chains";

export const client = createTestClient({
  chain: foundry,
  mode: "anvil",
  name: "Anvil Client",
  transport: http(),
})
  .extend(publicActions)
  .extend(walletActions);
