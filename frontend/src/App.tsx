import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import "./App.css";
import { useEffect, useState } from "react";
import { Product } from "./lib/types";
import { EPOS } from "./lib/EPOS";
import { client } from "./lib/client";
import { productData } from "./lib/constants";
import ProductGrid from "./components/ProductGrid";
import ProductPage from "./components/ProductPage";

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

export default App;
