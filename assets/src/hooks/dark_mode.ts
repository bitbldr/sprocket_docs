import { ClientHook } from "sprocket-js";

const isDarkMode = () =>
  window.matchMedia &&
  window.matchMedia("(prefers-color-scheme: dark)").matches;

let systemDarkModeListener: EventListener;

const addSystemDarkModeListener = (fn: (mode: "light" | "dark") => void) => {
  systemDarkModeListener = (event: any) => {
    if (event.matches && localStorage.theme !== "light") fn("dark");
    if (!event.matches && localStorage.theme !== "dark") fn("light");
  };

  window
    .matchMedia("(prefers-color-scheme: dark)")
    .addEventListener("change", systemDarkModeListener);
};

const removeSystemDarkModeListener = () =>
  window
    .matchMedia("(prefers-color-scheme: dark)")
    .removeEventListener("change", systemDarkModeListener);

function findOrCreateMeteThemeColorElement(selector: string): Element {
  const metaThemeColor = document.querySelector(selector);
  if (!metaThemeColor) {
    document.head
      .appendChild(document.createElement("meta"))
      .setAttribute("name", "theme-color");
  }

  return document.querySelector(selector) as Element;
}

// Set the <meta name="theme-color"> tag for mobile browsers to render correct colors
function setMetaThemeColor(mode: "auto" | "light" | "dark") {
  const metaThemeColor = findOrCreateMeteThemeColorElement(
    "meta[name=theme-color]"
  );

  const lightColor = "#ffffff";
  const darkColor = "#121212";

  if (mode === "auto") {
    metaThemeColor.setAttribute(
      "content",
      isDarkMode() ? darkColor : lightColor
    );
  } else if (mode === "dark") {
    metaThemeColor.setAttribute("content", darkColor);
  } else {
    metaThemeColor.setAttribute("content", lightColor);
  }
}

type Mode = "auto" | "light" | "dark";

function setDataThemeAttribute(mode: Mode) {
  const maybeLink = document.getElementById("highlight-theme");
  maybeLink && document.head.removeChild(maybeLink);

  const link = document.createElement("link");
  link.id = "highlight-theme";
  link.rel = "stylesheet";
  link.type = "text/css";

  if (mode === "light") {
    link.href =
      "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-light.min.css";
    document.head.appendChild(link);
  } else if (mode === "dark") {
    link.href =
      "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-dark.min.css";
    document.head.appendChild(link);
  }
}

const applyMode = (mode: Mode) => {
  if (mode === "auto") {
    if (isDarkMode()) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  } else if (mode === "dark") {
    document.documentElement.classList.add("dark");
  } else {
    document.documentElement.classList.remove("dark");
  }

  setMetaThemeColor(mode);
  setDataThemeAttribute(mode);
};

const mode = localStorage.theme || "auto";

document.addEventListener("DOMContentLoaded", () => applyMode(mode));

export const DarkMode: ClientHook = {
  create({ el, pushEvent, handleEvent }) {
    pushEvent("set_mode", mode);

    handleEvent("set_mode", (mode) => {
      localStorage.theme = mode;

      applyMode(mode);
    });

    addSystemDarkModeListener((mode) => applyMode(mode));
  },
  destroy() {
    removeSystemDarkModeListener();
  },
};
