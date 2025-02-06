export const ScrollObserver = {
  create({ el, pushEvent }) {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) {
            pushEvent("out_of_view");
          } else {
            pushEvent("in_view");
          }
        });
      },
      { threshold: 0 } // Fires when the element is fully out of view
    );

    // Wait for the element to be rendered to prevent the observer from firing immediately
    setTimeout(() => observer.observe(el), 100);
  },
};
