export const DoubleClick = {
  create({ el, pushEvent }) {
    el.addEventListener("dblclick", () => {
      pushEvent("doubleclick", {});
    });
  },
};
