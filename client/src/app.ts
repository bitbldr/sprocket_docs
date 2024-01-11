import { Doubleclick } from "./hooks/doubleclick";
import { DarkMode } from "./hooks/dark_mode";
// import { connect } from "sprocket-js";
import { connect } from "../../../sprocket/client/src/sprocket";

const hooks = {
  Doubleclick,
  DarkMode,
};

window.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document
    .querySelector("meta[name=csrf-token]")
    ?.getAttribute("content");

  if (csrfToken) {
    let livePath =
      window.location.pathname === "/"
        ? "/live"
        : window.location.pathname.split("/").concat("live").join("/");

    connect(livePath, {
      csrfToken,
      // targetEl: document.querySelector("#app") as Element,
      hooks,
    });
  } else {
    console.error("Missing CSRF token");
  }
});
