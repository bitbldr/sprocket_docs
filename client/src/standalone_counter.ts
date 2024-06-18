// import { connect } from "sprocket-js";
import { connect } from "../../../sprocket/client/src/sprocket";

window.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document
    .querySelector("meta[name=csrf-token]")
    ?.getAttribute("content");

  if (csrfToken) {
    connect("/components/counter/connect", {
      csrfToken,
      targetEl: document.getElementById("counter") as Element,
    });

    connect("/components/counter/connect", {
      csrfToken,
      targetEl: document.getElementById("no-first-paint-counter") as Element,
    });
  } else {
    console.error("Missing CSRF token");
  }
});
