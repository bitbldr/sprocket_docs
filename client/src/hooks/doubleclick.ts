export const Doubleclick = {
  mounted({ el, pushEvent }) {
    el.addEventListener("dblclick", () => {
      pushEvent("doubleclick", {});
    });
  },
};
