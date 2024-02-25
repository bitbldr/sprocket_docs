interface MaybeClickOutsideMouseEvent extends MouseEvent {
  clickOutside?: boolean;
}

export const ClickOutside = {
  create({ el, pushEvent }) {
    el.addEventListener("click", (e: MouseEvent) => {
      (e as MaybeClickOutsideMouseEvent).clickOutside = true;
    });

    document.addEventListener("click", (e: MaybeClickOutsideMouseEvent) => {
      if (!e.clickOutside) {
        pushEvent("click_outside", {});
      }
    });
  },
};
