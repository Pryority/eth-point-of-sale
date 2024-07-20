import { Input } from "./ui/input";

const Header = () => {
  return (
    <header className="flex w-full items-center justify-between h-16 px-4 md:px-6 bg-background border-b">
      <a href="/" className="text-lg font-semibold">
        ETH Point of Sale
      </a>
      <div className="relative flex-1 max-w-md mx-4">
        <SearchIcon className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
        <Input
          type="search"
          placeholder="Search products..."
          className="pl-8 w-full"
        />
      </div>
      <nav className="hidden md:flex items-center gap-4">
        <a
          href="#"
          className="text-sm font-medium hover:underline underline-offset-4"
        >
          Home
        </a>
        <a
          href="#"
          className="text-sm font-medium hover:underline underline-offset-4"
        >
          Products
        </a>
        <a
          href="#"
          className="text-sm font-medium hover:underline underline-offset-4"
        >
          About
        </a>
        <a
          href="#"
          className="text-sm font-medium hover:underline underline-offset-4"
        >
          Contact
        </a>
      </nav>
    </header>
  );
};

// @ts-expect-error: props needs type
function SearchIcon(props) {
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
      <circle cx="11" cy="11" r="8" />
      <path d="m21 21-4.3-4.3" />
    </svg>
  );
}

export default Header;
