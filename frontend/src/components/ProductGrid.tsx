import useStore from "@/lib/hooks/useStore";
import { Product } from "@/lib/types";

type ProductGridProps = {
  products: Product[] | null;
};

const ProductSkeleton = () => (
  <div className="animate-pulse">
    <div className="overflow-hidden rounded-lg bg-gray-300 h-60"></div>
    <div className="mt-4 space-y-2">
      <div className="h-4 bg-gray-300 rounded w-3/4"></div>
      <div className="h-4 bg-gray-300 rounded w-5/6"></div>
      <div className="h-4 bg-gray-300 rounded w-1/2"></div>
    </div>
  </div>
);

export default function ProductGrid(props: ProductGridProps) {
  const { products } = props;
  const [store] = useStore();

  const productsState = store.products;

  return (
    <section className="container px-4 md:px-6 py-12">
      {productsState?.error && <p>Error: {productsState?.error}</p>}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">
        {productsState?.loading ? (
          // Render skeleton placeholders
          Array.from({ length: 8 }).map((_, index) => (
            <ProductSkeleton key={index} />
          ))
        ) : products ? (
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
