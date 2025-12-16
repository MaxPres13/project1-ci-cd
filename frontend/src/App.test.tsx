import { render, screen } from "@testing-library/react";
import App from "./App";

test("renders React Vite app", () => {
	render(<App />);
	expect(screen.getByText(/CD Prozess/i)).toBeInTheDocument();
});
