import { atom, useAtom } from "jotai";
import { Address } from "viem";
import { Product } from "../types";

export type CartItem = {
  product: Product;
  quantity: number;
};

export type CartState = {
  owner: Address | null;
  items: CartItem[];
};

const cartAtom = atom<CartState>({
  owner: null,
  items: [],
});

export default function useCart() {
  return useAtom(cartAtom);
}
