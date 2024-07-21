import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import "./App.css";
import { useEffect } from "react";
import { Product } from "./lib/types";
import { EPOS } from "./lib/EPOS";
import { client, memoryClient } from "./lib/client";
import { productData } from "./lib/constants";
import ProductGrid from "./components/ProductGrid";
import ProductPage from "./components/ProductPage";
import Header from "./components/Header";
import useStore from "./lib/hooks/useStore";
import { Toaster } from "./components/ui/sonner";

function App() {
  const [store, setStore] = useStore();
  useEffect(() => {
    const fetchProducts = async () => {
      setStore((prev) => ({
        ...prev,
        products: {
          data: null,
          loading: true,
          error: null,
        },
      }));
      try {
        const fetchedProducts = await EPOS.getProducts(client);
        const blockNumber = await memoryClient.getBlockNumber();
        console.log("blockNumber", blockNumber);
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
          console.log("Products:", products);
          setStore((prev) => ({
            ...prev,
            products: { data: products, loading: false, error: null },
          }));
        } else {
          console.error("No active products fetched.");
          setStore((prev) => ({
            ...prev,
            products: {
              data: null,
              loading: false,
              error: "No active products fetched.",
            },
          }));
        }
      } catch (error) {
        console.error("Could not fetch products:", error);
        setStore((prev) => ({
          ...prev,
          products: {
            data: null,
            loading: false,
            error: "Could not fetch products.",
          },
        }));
      }
    };

    fetchProducts();
  }, [setStore]);

  return (
    <Router>
      <div className="flex flex-col min-h-screen w-screen items-center">
        <Header />
        <Routes>
          <Route
            path="/"
            element={
              <ProductGrid
                products={store.products ? store.products.data : []}
              />
            }
          />
          <Route
            path="/product/:id"
            element={
              <ProductPage
                products={store.products ? store.products.data : []}
              />
            }
          />
        </Routes>
      </div>
      <Toaster />
    </Router>
  );
}

export default App;
