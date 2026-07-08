import { useState } from "react";
import Button from "../components/Button";


const API_URL = import.meta.env.VITE_API_URL;


export default function Home() {
  const [Message , setMessage] = useState('Not Response yet.');

  const handleCreate = async () => {
    try {
      const response = await fetch(`${API_URL}/create`, {
        method: 'POST',
        headers: {
          'Content-type': 'application/json'
        },
        body: JSON.stringify({
          name: 'khoi',
          age: 21
        })
      })

      const data = await response.json();
      setMessage(JSON.stringify(data, null, 2));
    } catch (error) {
      setMessage(`Error: ${error}`)
    }
  };

  const handleGet = async () => {
    try {
      const response = await fetch(`${API_URL}/getinfor`);

      const data = await response.json();
      setMessage(JSON.stringify(data, null, 2));

    } catch (error) {
      setMessage(`Error: ${error}`)
    }
  };

  const handleDelete = async () => {
    try {
      const response = await fetch(`${API_URL}/delete/1`, {
        method: 'DELETE'
      })

      const data = await response.json();
      setMessage(JSON.stringify(data, null, 2));
    } catch (error) {
      setMessage(`Error: ${error}`)
    }
  };

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        marginTop: "100px",
        gap: "20px",
      }}
    >
      <h1>React CRUD Demo</h1>

      <Button
        text="Create"
        onClick={handleCreate}
      />

      <Button
        text="Get Information"
        onClick={handleGet}
      />

      <Button
        text="Delete"
        onClick={handleDelete}
      />

      <div style={{ width: "500px" }}>
        <strong>Response</strong>

        <pre
          style={{
            textAlign: "left",
            background: "#f5f5f5",
            padding: "12px",
            borderRadius: "8px",
            whiteSpace: "pre-wrap",
          }}
        >
          {Message}
        </pre>
      </div>
    </div>
    
  );
}