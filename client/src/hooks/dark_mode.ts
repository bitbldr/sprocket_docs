const isDarkMode = () =>
  window.matchMedia &&
  window.matchMedia("(prefers-color-scheme: dark)").matches;

let systemDarkModeListener: EventListener;

const addSystemDarkModeListener = (fn: (mode: "light" | "dark") => void) => {
  systemDarkModeListener = (event: any) => {
    event.matches ? fn("dark") : fn("light");
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
function setMetaThemeColor(dark: boolean) {
  const metaThemeColor = findOrCreateMeteThemeColorElement(
    "meta[name=theme-color]"
  );

  const lightColor = "#ffffff";
  const darkColor = "#121212";

  if (dark) {
    metaThemeColor.setAttribute("content", darkColor);
  } else {
    metaThemeColor.setAttribute("content", lightColor);
  }
}

const applyMode = (mode: "auto" | "light" | "dark") => {
  if (mode === "auto") {
    if (isDarkMode()) {
      document.documentElement.classList.add("dark");
      setMetaThemeColor(true);
    } else {
      document.documentElement.classList.remove("dark");
      setMetaThemeColor(false);
    }
  } else if (mode === "dark") {
    document.documentElement.classList.add("dark");
    setMetaThemeColor(true);
  } else {
    document.documentElement.classList.remove("dark");
    setMetaThemeColor(false);
  }
};

const mode = localStorage.theme || "auto";

document.addEventListener("DOMContentLoaded", () => applyMode(mode));

export const DarkMode = {
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
