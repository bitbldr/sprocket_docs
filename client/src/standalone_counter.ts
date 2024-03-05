import { connect } from "sprocket-js";

window.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document
    .querySelector("meta[name=csrf-token]")
    ?.getAttribute("content");

  if (csrfToken) {
    connect("/counter/connect", {
      csrfToken,
      targetEl: document.getElementById("counter") as Element,
    });

    connect("/counter/connect", {
      csrfToken,
      targetEl: document.getElementById("no-first-paint-counter") as Element,
    });
  } else {
    console.error("Missing CSRF token");
  }
});
