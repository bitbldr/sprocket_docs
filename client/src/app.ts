import { connect } from "sprocket-js";
import { DoubleClick } from "./hooks/double_click";
import { DarkMode } from "./hooks/dark_mode";
import { CodeBlock } from "./hooks/codeblock";
import { HighlightJS } from "./hooks/hljs";
import { ClickOutside } from "./hooks/click_outside";
import { LoadComponents } from "./hooks/load_components";

const hooks = {
  CodeBlock,
  DoubleClick,
  DarkMode,
  ClickOutside,
  LoadComponents,
  HighlightJS,
};

window.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document
    .querySelector("meta[name=csrf-token]")
    ?.getAttribute("content");

  if (csrfToken) {
    let connectPath =
      window.location.pathname === "/"
        ? "/connect"
        : window.location.pathname.split("/").concat("connect").join("/");

    connect(connectPath, {
      csrfToken,
      targetEl: document.querySelector("#app") as Element,
      hooks,
    });
  } else {
    console.error("Missing CSRF token");
  }
});
