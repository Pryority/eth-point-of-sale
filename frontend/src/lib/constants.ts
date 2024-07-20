import { Product } from "./types";

export const productData: {
  [key: string]: Partial<Pick<Product, "name" | "description" | "image">>;
} = {
  "1": {
    name: "Iced Coffee",
    description: "A yummy drink to refuel your stamina.",
    image: new URL("../assets/iced-coffee.jpg", import.meta.url).href,
  },
  "2": {
    name: "Chocolate Chip Cookie",
    description: "A delectable treat.",
    image: new URL("../assets/chocolate-chip-cookie.jpg", import.meta.url).href,
  },
  "3": {
    name: "Orange",
    description: "A juicy citrus fruit",
    image: "https://picsum.photos/seed/orange3/300/300",
  },
  "4": {
    name: "Mango",
    description: "A sweet tropical fruit with a large pit",
    image: "https://picsum.photos/seed/mango4/300/300",
  },
};
