import { createTestClient, http, publicActions, walletActions } from "viem";
import { createMemoryClient } from "tevm";
import { foundry } from "viem/chains";
// import { anvil } from "tevm/common";

export const client = createTestClient({
  chain: foundry,
  mode: "anvil",
  name: "Anvil Client",
  transport: http(),
})
  .extend(publicActions)
  .extend(walletActions);

export const memoryClient = createMemoryClient({
  // common: anvil,
  fork: {
    // @warning we may face throttling using the public endpoint
    // In production apps consider using `loadBalance` and `rateLimit` transports
    transport: http("http://localhost:8545")({}),
  },
});
