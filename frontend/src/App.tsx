import {
  BrowserRouter as Router,
  Route,
  Routes,
  useParams,
} from "react-router-dom";
import "./App.css";
import { Button } from "./components/ui/button";
import { useEffect, useState } from "react";
import { Product } from "./lib/types";
import { EPOS } from "./lib/EPOS";
import { client } from "./lib/client";
import { productData } from "./lib/constants";

type ProductGridProps = {
  products: Product[] | null;
};
type ProductPageProps = {
  products: Product[] | null;
};
function ProductGrid(props: ProductGridProps) {
  const { products } = props;
  return (
    <section className="container px-4 md:px-6 py-12">
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">
        {products ? (
          products.map((product) => (
            <a
              key={product.id}
              href={`/product/${product.id}`}
              className="relative group"
            >
              <div className="overflow-hidden rounded-lg">
                <img
                  src={product.image}
                  alt={product.name}
                  width={400}
                  height={400}
                  className="w-full h-60 object-cover group-hover:scale-105 transition-transform"
                />
              </div>
              <div className="mt-4">
                <h3 className="text-lg font-semibold">{product.name}</h3>
                <p className="text-muted-foreground">{product.description}</p>
                <p className="text-base font-semibold">
                  ${product.price.toFixed(2)}
                </p>
              </div>
            </a>
          ))
        ) : (
          <p>Store has no products.</p>
        )}
      </div>
    </section>
  );
}

function ProductPage(props: ProductPageProps) {
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
          <div className="grid md:grid-cols-4 gap-2">
            <button className="border rounded-lg overflow-hidden transition-colors hover:border-primary">
              <img
                src="/placeholder.svg"
                alt="Thumbnail 1"
                width={100}
                height={100}
                className="aspect-square object-cover"
              />
            </button>
            <button className="border rounded-lg overflow-hidden transition-colors hover:border-primary">
              <img
                src="/placeholder.svg"
                alt="Thumbnail 2"
                width={100}
                height={100}
                className="aspect-square object-cover"
              />
            </button>
            <button className="border rounded-lg overflow-hidden transition-colors hover:border-primary">
              <img
                src="/placeholder.svg"
                alt="Thumbnail 3"
                width={100}
                height={100}
                className="aspect-square object-cover"
              />
            </button>
            <button className="border rounded-lg overflow-hidden transition-colors hover:border-primary">
              <img
                src="/placeholder.svg"
                alt="Thumbnail 4"
                width={100}
                height={100}
                className="aspect-square object-cover"
              />
            </button>
          </div>
        </div>
      </div>
      <div className="grid gap-6">
        <div>
          <h1 className="text-3xl font-bold">{product.name}</h1>
          <p className="text-muted-foreground">{product.description}</p>
        </div>
        <div className="grid gap-2">
          <div className="flex items-center gap-2">
            <StarIcon className="w-5 h-5 fill-primary" />
            <StarIcon className="w-5 h-5 fill-primary" />
            <StarIcon className="w-5 h-5 fill-primary" />
            <StarIcon className="w-5 h-5 fill-muted stroke-muted-foreground" />
            <StarIcon className="w-5 h-5 fill-muted stroke-muted-foreground" />
          </div>
          <div className="text-4xl font-bold">${product.price}</div>
        </div>
        <div className="grid gap-4">
          <p className="text-muted-foreground">
            Introducing the Acme Prism T-Shirt, a perfect blend of style and
            comfort for the modern individual. This tee is crafted with a
            meticulous composition of 60% combed ringspun cotton and 40%
            polyester jersey, ensuring a soft and breathable fabric that feels
            gentle against the skin.
          </p>
          <p className="text-muted-foreground">
            The design of the Acme Prism T-Shirt is as striking as it is
            comfortable. The shirt features a unique prism-inspired pattern that
            adds a modern and eye-catching touch to your ensemble.
          </p>
        </div>
        <Button size="lg">Add to Cart</Button>
      </div>
    </div>
  );
}

function App() {
  const [products, setProducts] = useState<Product[] | null>(null);
  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const fetchedProducts = await EPOS.getProducts(client);
        console.log("Fetched products:", fetchedProducts);

        if (fetchedProducts && fetchedProducts.length > 0) {
          const products: Product[] = fetchedProducts.map(([id, product]) => ({
            id: Number(id),
            price: Number(product.price) / 100,
            stock: Number(product.stock),
            name: productData[id.toString()]?.name ?? `Product ${id}`,
            description: productData[id.toString()]?.description ?? "",
            image:
              productData[id.toString()]?.image ??
              "https://example.com/image.png",
          }));
          console.log("Processed products:", products);
          setProducts(products);
        } else {
          console.error("No active products fetched.");
        }
      } catch (error) {
        console.error("Could not fetch products:", error);
      }
    };

    fetchProducts();
  }, []);

  return (
    <Router>
      <div className="flex flex-col min-h-screen w-screen items-center">
        <nav>
          <h1>ETH Point of Sale</h1>
        </nav>
        <Routes>
          <Route path="/" element={<ProductGrid products={products} />} />
          <Route
            path="/product/:id"
            element={<ProductPage products={products} />}
          />
        </Routes>
      </div>
    </Router>
  );
}

// @ts-expect-error: props needs type
function StarIcon(props) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
    </svg>
  );
}
export default App;

// const products: Product[] = [
//   {
//     id: 1,
//     name: "Acme Circles T-Shirt",
//     description: "60% combed ringspun cotton/40% polyester jersey tee.",
//     price: 29.99,
//     image: "https://picsum.photos/seed/tshirt1/300/300",
//   },
//   {
//     id: 2,
//     name: "Sunset Shades Sunglasses",
//     description: "UV Protection Eyewear",
//     price: 49.99,
//     image: "https://picsum.photos/seed/sunglasses2/300/300",
//   },
//   {
//     id: 3,
//     name: "Cool Breeze Portable Fan",
//     description: "On-the-Go Cooling",
//     price: 24.99,
//     image: "https://picsum.photos/seed/fan3/300/300",
//   },
//   {
//     id: 4,
//     name: "Summer Breeze T-Shirt",
//     description: "Lightweight Cotton Shirt",
//     price: 19.99,
//     image: "https://picsum.photos/seed/tshirt4/300/300",
//   },
//   {
//     id: 5,
//     name: "Sunset Beach Shorts",
//     description: "Quick-Dry Swim Shorts",
//     price: 34.99,
//     image: "https://picsum.photos/seed/shorts5/300/300",
//   },
//   {
//     id: 6,
//     name: "Sunset Beach Pants",
//     description: "Lightweight Cotton Pants",
//     price: 39.99,
//     image: "https://picsum.photos/seed/pants6/300/300",
//   },
//   {
//     id: 7,
//     name: "Sunset Beach Towel",
//     description: "Absorbent Cotton Towel",
//     price: 14.99,
//     image: "https://picsum.photos/seed/towel7/300/300",
//   },
//   {
//     id: 8,
//     name: "Flexi Wearables",
//     description: "Comfortable Fitness Gear",
//     price: 59.99,
//     image: "https://picsum.photos/seed/wearables8/300/300",
//   },
// ];
