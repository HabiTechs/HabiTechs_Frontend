import React from "react";

// PR15: Componente dummy NotificationCard
export default function NotificationCard({ message, date }) {
  return (
    <div>
      <p>{message}</p>
      <small>{date}</small>
    </div>
  );
}