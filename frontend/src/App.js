import React, { useState } from "react";

function App() {
  const [image1, setImage1] = useState(null);
  const [image2, setImage2] = useState(null);
  const [preview1, setPreview1] = useState(null);
  const [preview2, setPreview2] = useState(null);
  const [result, setResult] = useState("");
  const [loading, setLoading] = useState(false);

  const handleFileChange1 = (e) => {
    const file = e.target.files[0];
    setImage1(file);
    setPreview1(URL.createObjectURL(file));
    setResult("");
  };

  const handleFileChange2 = (e) => {
    const file = e.target.files[0];
    setImage2(file);
    setPreview2(URL.createObjectURL(file));
    setResult("");
  };

  const handleVerify = async () => {
    if (!image1 || !image2) {
      alert("Please select both images!");
      return;
    }

    setLoading(true);
    setResult("Processing...");

    const formData = new FormData();
    formData.append("img1", image1);
    formData.append("img2", image2);

    try {
      const response = await fetch("http://localhost:5000/verify", {

        method: "POST",
        body: formData,
      });

      const data = await response.json();
      setResult(JSON.stringify(data, null, 2));
    } catch (err) {
      setResult("Error: " + err.message);
    }

    setLoading(false);
  };

  return (
    <div style={{ fontFamily: "Arial", margin: 40 }}>
      <h2>DeepFace API Verify Demo (React)</h2>

      <div>
        <label>Image 1: </label>
        <input type="file" accept="image/*" onChange={handleFileChange1} />
        {preview1 && (
          <img
            src={preview1}
            alt="Preview 1"
            style={{ width: 150, marginTop: 10, borderRadius: 8 }}
          />
        )}
      </div>

      <div>
        <label>Image 2: </label>
        <input type="file" accept="image/*" onChange={handleFileChange2} />
        {preview2 && (
          <img
            src={preview2}
            alt="Preview 2"
            style={{ width: 150, marginTop: 10, borderRadius: 8 }}
          />
        )}
      </div>

      <br />
      <button onClick={handleVerify} disabled={loading}>
        {loading ? "Processing..." : "Verify Face"}
      </button>

      <div
        id="result"
        style={{
          marginTop: 20,
          whiteSpace: "pre-wrap",
          background: "#f5f5f5",
          padding: 10,
        }}
      >
        {result}
      </div>
    </div>
  );
}

export default App;

//aaaaaa