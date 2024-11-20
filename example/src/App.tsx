import React, { useState } from "react";
import { calculateSomething } from "@react-components/common";

const App = () => {
  const [result, setResult] = useState<number | null>(null);

  const handleClick = () => {
    // Simulate random numbers
    const num1 = Math.floor(Math.random() * 100);
    const num2 = Math.floor(Math.random() * 100);

    // Call the `calculateSomething` function
    const sum = calculateSomething(num1, num2);
    setResult(sum);
  };

  return (
    <div style={{ padding: "20px", textAlign: "center" }}>
      <button onClick={handleClick}>
        {result === null
          ? "Click me to add numbers!"
          : `Result: ${result}`}
      </button>
    </div>
  );
};

export default App;
