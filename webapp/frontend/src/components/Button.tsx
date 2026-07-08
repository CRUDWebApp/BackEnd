type Props = {
  text: string;
  onClick: () => void;
};

export default function Button({ text, onClick }: Props) {
  return (
    <button
      onClick={onClick}
      style={{
        width: "200px",
        padding: "12px",
        fontSize: "16px",
        cursor: "pointer",
        borderRadius: "8px",
        border: "1px solid #ccc",
      }}
    >
      {text}
    </button>
  );
}