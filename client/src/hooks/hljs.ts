import hljs from "highlight.js";
import gleam from "@gleam-lang/highlight.js-gleam";
import { ClientHook } from "sprocket-js";

hljs.registerLanguage("gleam", gleam);

export const HighlightJS: ClientHook = {
  create() {
    setTimeout(() => {
      hljs.highlightAll();
    }, 0);
  },
};
