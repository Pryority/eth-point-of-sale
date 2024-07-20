import { Product } from "@/lib/types";
import { useParams } from "react-router-dom";
import { Button } from "./ui/button";

type ProductPageProps = {
  products: Product[] | null;
};

export default function ProductPage(props: ProductPageProps) {
  const { products } = props;
  const { id } = useParams<{ id: string }>();
  if (!id) return;
  const productId = parseInt(id);

  if (!products) {
    return <div>Inventory not found</div>;
  }

  const product = products.find((p) => p.id === productId);

  if (!product) {
    return <div>Product not found</div>;
  }

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
        <Button size="lg">Add to Cart</Button>
      </div>
    </div>
  );
}
