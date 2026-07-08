import { useState } from "react";
import Button from "../components/Button";

export default function Home() {
  const [Message , setMessage] = useState('');

  const handleCreate = () => {
    setMessage('Hello-world-Create')
    // TODO: gọi POST /users
  };

  const handleGet = () => {
    setMessage('Hello-world-Get Information')
    // TODO: gọi GET /users
  };

  const handleDelete = () => {
    setMessage('Hello-world-Delete')
    // TODO: gọi DELETE /users/:id
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

      <div>
        <strong>Response</strong>

        <p>{Message || "No Response yet."}</p>
      </div>
    </div>
    
  );
}