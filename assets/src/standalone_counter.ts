import { connect } from "sprocket-js";

window.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document
    .querySelector("meta[name=csrf-token]")
    ?.getAttribute("content");

  if (csrfToken) {
    connect("/components/counter/connect", {
      csrfToken,
      targetEl: document.getElementById("counter") as Element,
      initialProps: { initial: "100" },
    });

    connect("/components/counter/connect", {
      csrfToken,
      targetEl: document.getElementById("no-first-paint-counter") as Element,
      initialProps: { initial: "100" },
    });
  } else {
    console.error("Missing CSRF token");
  }
});
