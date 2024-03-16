import { connect } from "sprocket-js";
import { CodeBlock } from "./codeblock";

const hooks = {
  CodeBlock,
};

export const LoadComponents = {
  create({ el }) {
    const csrfToken = document
      .querySelector("meta[name=csrf-token]")
      ?.getAttribute("content");

    el.querySelectorAll("[data-sprocket]").forEach((el) => {
      const name = el.getAttribute("data-sprocket");

      connect(`/components/${name}/connect`, {
        csrfToken,
        targetEl: el.firstElementChild,
        hooks,
      });
    });
  },
};
