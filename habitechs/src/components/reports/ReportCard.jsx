import React from "react";

// PR13: Componente dummy ReportCard
export default function ReportCard({ title, description }) {
  return (
    <div>
      <h4>{title}</h4>
      <p>{description}</p>
    </div>
  );
}
