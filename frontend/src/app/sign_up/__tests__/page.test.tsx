import "@testing-library/jest-dom";
import { render, screen } from "@testing-library/react";
import Page from "../page";

describe("Page", () => {
  it("should render title", async () => {
    render(<Page />);
    const heading = screen.getByText("Sign Up");
    expect(heading).toBeInTheDocument();
  })
});
