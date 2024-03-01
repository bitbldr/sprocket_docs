interface MaybeClickOutsideMouseEvent extends MouseEvent {
  self?: boolean;
}

export const ClickOutside = {
  create({ el, pushEvent, handleEvent }) {
    el.addEventListener("click", (e: MouseEvent) => {
      (e as MaybeClickOutsideMouseEvent).self = true;
    });

    document.addEventListener("click", (e: MaybeClickOutsideMouseEvent) => {
      if (!e.self) {
        pushEvent("click_outside", {});
      }
    });
  },
};
