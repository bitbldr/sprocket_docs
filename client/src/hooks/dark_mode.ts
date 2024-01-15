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

export const DarkMode = {
  create({ el, pushEvent, handleEvent }) {
    const mode = localStorage.theme
      ? localStorage.theme
      : isDarkMode()
      ? "auto-dark"
      : "auto-light";
    pushEvent("set_mode", mode);

    handleEvent("set_mode", (mode) => {
      localStorage.theme = mode;
    });

    addSystemDarkModeListener((mode) => {
      if (!("theme" in localStorage)) {
      }
    });
  },
  destroy() {
    removeSystemDarkModeListener();
  },
};
