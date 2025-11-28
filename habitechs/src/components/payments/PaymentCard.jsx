import React from "react";

// PR12: Componente dummy PaymentCard
export default function PaymentCard({ resident, amount, date }) {
  return (
    <div>
      <h4>{resident}</h4>
      <p>Monto: {amount}</p>
      <p>Fecha: {date}</p>
    </div>
  );
}
