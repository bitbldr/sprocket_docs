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

const applyMode = (mode: "auto" | "light" | "dark") => {
  if (mode === "auto") {
    if (isDarkMode()) {
      document.documentElement.classList.add("dark");
    }
  } else if (mode === "dark") {
    document.documentElement.classList.add("dark");
  } else {
    document.documentElement.classList.remove("dark");
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
