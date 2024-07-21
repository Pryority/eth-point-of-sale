import { Product } from "@/lib/types";
import { useParams } from "react-router-dom";
import { Button } from "./ui/button";
import useCart from "@/lib/hooks/useCart";
import { useState } from "react";
import { Minus, Plus } from "lucide-react";
import { toast } from "sonner";

type ProductPageProps = {
  products: Product[] | null;
};

export default function ProductPage(props: ProductPageProps) {
  const { products } = props;
  const [cart, setCart] = useCart();
  const { id } = useParams<{ id: string }>();
  const [quantity, setQuantity] = useState(1);

  if (!id) return null;

  const productId = parseInt(id);

  if (!products) {
    return <div>Inventory not found</div>;
  }

  const product = products.find((p) => p.id === productId);

  if (!product) {
    return <div>Product not found</div>;
  }

  const handleAdd = () => {
    const prevCartState = { ...cart };

    let totalQuantity = quantity;

    setCart((prev) => {
      const existingItemIndex = prev.items.findIndex(
        (item) => item.product.id === product.id,
      );

      if (existingItemIndex !== -1) {
        const updatedItems = [...prev.items];
        updatedItems[existingItemIndex].quantity += quantity;
        totalQuantity = updatedItems[existingItemIndex].quantity;
        return { ...prev, items: updatedItems };
      } else {
        return {
          ...prev,
          items: [...prev.items, { product, quantity }],
        };
      }
    });
    console.log(cart);
    toast(`Added ${quantity} ${product.name} to cart.`, {
      description: `${totalQuantity} in total`,
      action: {
        label: "Undo",
        onClick: () => {
          setCart(prevCartState);
          toast(`Removed ${quantity} ${product.name} from cart.`, {
            description: `${totalQuantity - quantity} in total`,
          });
        },
      },
    });
  };

  const handleIncrement = () => {
    setQuantity((prevQuantity) => prevQuantity + 1);
  };

  const handleDecrement = () => {
    setQuantity((prevQuantity) => Math.max(1, prevQuantity - 1));
  };

  return (
    <div className="grid md:grid-cols-2 gap-8 max-w-6xl mx-auto py-12 px-4 md:px-0">
      <div className="grid gap-4">
        <div className="grid gap-2">
          <img
            src={product.image}
            alt="Product Image"
            width={600}
            height={600}
            className="aspect-square object-cover border rounded-lg"
          />
        </div>
      </div>
      <div className="grid gap-6">
        <div>
          <h1 className="text-3xl font-bold">{product.name}</h1>
          <p className="text-muted-foreground">{product.description}</p>
        </div>
        <div className="grid gap-2">
          <div className="text-4xl font-bold">${product.price}</div>
        </div>
        <div className="grid grid-cols-7 gap-4 bg-secondary w-full p-1 rounded-lg">
          <Button
            variant="outline"
            size="icon"
            className="w-full col-span-2"
            onClick={handleDecrement}
          >
            <Minus className="h-4 w-4" />
            <span className="sr-only">Decrease quantity</span>
          </Button>
          <div className="text-2xl font-medium col-span-3 text-center">
            {quantity}
          </div>
          <Button
            variant="outline"
            size="icon"
            className="w-full col-span-2"
            onClick={handleIncrement}
          >
            <Plus className="h-4 w-4" />
            <span className="sr-only">Increase quantity</span>
          </Button>
        </div>
        <Button size="lg" onClick={handleAdd}>
          Add to Cart
        </Button>
      </div>
    </div>
  );
}
