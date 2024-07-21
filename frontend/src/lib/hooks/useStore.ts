import { atom, useAtom } from "jotai";
import { Address } from "viem";
import { Product } from "../types";

export type StoreState = {
  address: Address | null;
  owner: Address | null;
  balance: bigint | null;
  itemCount: number | null;
  products: {
    data: Product[] | null;
    loading: boolean | null;
    error: string | null;
  } | null;
};

const storeAtom = atom<StoreState>({
  address: null,
  owner: null,
  balance: BigInt(0),
  itemCount: 0,
  products: {
    data: null,
    loading: false,
    error: null,
  },
});

export default function useStore() {
  return useAtom(storeAtom);
}
