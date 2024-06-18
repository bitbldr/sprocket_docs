// import { connect } from "sprocket-js";
import { connect } from "../../../../sprocket/client/src/sprocket";
import { CodeBlock } from "./codeblock";
import { DoubleClick } from "./double_click";

const hooks = {
  CodeBlock,
  DoubleClick,
};

export const LoadComponents = {
  create({ el }) {
    const csrfToken = document
      .querySelector("meta[name=csrf-token]")
      ?.getAttribute("content");

    el.querySelectorAll("[data-sprocket]").forEach((el: Element) => {
      const name = el.getAttribute("data-sprocket");

      const props = Array.from(el.attributes)
        .filter(
          (attr) =>
            attr.name.startsWith("data-") && attr.name !== "data-sprocket"
        )
        // .map((attr) => [attr.name.substring(10), attr.value]);
        .reduce((acc, attr) => {
          acc[attr.name.substring(10)] = attr.value;
          return acc;
        }, {});

      // const query = new URLSearchParams(props).toString();

      connect(`/components/${name}/connect`, {
        csrfToken,
        targetEl: el.firstElementChild,
        hooks,
        initialProps: props,
      });
    });
  },
};
