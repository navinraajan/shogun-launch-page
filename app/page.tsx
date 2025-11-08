"use client";
import { useState, FormEvent } from "react";
import { motion } from "framer-motion";

export default function Home() {
  const [status, setStatus] = useState("");

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();

    const formData = new FormData(e.target as HTMLFormElement);
    const data = Object.fromEntries(formData.entries());

    setStatus("Sending...");

    try {
      const response = await fetch("https://script.google.com/macros/s/AKfycbzzy-oSbOELCPMrDUIZan0SYcWzLQSXXJBzjj91a0qBB_RZo2r1nkgVGv0nJ_5ke7UM/exec", {
        method: "POST",
        mode: "no-cors",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
      });

      // No response due to no-cors, so assume success
      setStatus("Thank you for joining!");
      (e.target as HTMLFormElement).reset();
    } catch (error) {
      setStatus("Failed to send. Please try again.");
    }
  }

  return (
    <>
      <div className="background-image" />
      <main>
        <motion.img
          src="/logo.png"
          alt="Shogun Logo"
          className="logo-glow"
          initial={{ opacity: 0, scale: 0.75 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 1.1, type: "spring" }}
          style={{ width: 94 }}
        />

        <motion.h1
          className="shogun-title"
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2, duration: 1 }}
        >
          SHOGŪN
        </motion.h1>

        <motion.div
          className="launch-msg"
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.45, duration: 0.85 }}
        >
          🗡️ We’re Launching Soon — A New Era of Intelligent Interaction
        </motion.div>

        <motion.p
          className="product-desc"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.7, duration: 1 }}
        >
          <b>Shogun</b> merges ancient wisdom with digital evolution—an AI warrior that thinks, adapts, and connects through emotion. Each avatar is a sentient digital being—expressive, powerful, and aware. The age of passive chatbots is over; the <b>Shogun Era</b> begins.
        </motion.p>

        <motion.form
          initial={{ opacity: 0, y: 18 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1, duration: 0.8 }}
          onSubmit={handleSubmit}
        >
          <input
            type="email"
            name="email"
            placeholder="Enter your email to join the launch"
            required
            style={{ padding: "12px 20px", borderRadius: "8px", border: "none", fontSize: "1rem", outline: "none" }}
          />
          <button type="submit" style={{ padding: "12px 35px", borderRadius: "8px", fontWeight: "bold", cursor: "pointer" }}>
            Join
          </button>
        </motion.form>
        <div style={{ marginTop: 10, minHeight: 20, color: "#fff" }}>{status}</div>
      </main>
    </>
  );
}
