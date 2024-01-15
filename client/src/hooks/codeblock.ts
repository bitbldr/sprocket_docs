import hljs from "highlight.js";
import gleam from "@gleam-lang/highlight.js-gleam";
import { ClientHook } from "../../../../sprocket/client/src/sprocket";

hljs.registerLanguage("gleam", gleam);

export const CodeBlock: ClientHook = {
  create({ el }) {
    hljs.highlightElement(el as HTMLElement);
  },
};
