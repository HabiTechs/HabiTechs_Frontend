import React from "react";

// PR10: Componente dummy ResidentCard
export default function ResidentCard({ name, unit }) {
  return (
    <div>
      <h3>{name}</h3>
      <p>Unidad: {unit}</p>
    </div>
  );
}
