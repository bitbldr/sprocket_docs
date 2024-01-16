interface MaybeClickOutsideMouseEvent extends MouseEvent {
  click_outside?: boolean;
}

export const ClickOutside = {
  create({ el, pushEvent }) {
    el.addEventListener("click", (e: MouseEvent) => {
      (e as MaybeClickOutsideMouseEvent).click_outside = true;
    });

    document.addEventListener("click", (e: MaybeClickOutsideMouseEvent) => {
      if (!e.click_outside) {
        pushEvent("click_outside", {});
      }
    });
  },
};
