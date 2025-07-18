import docs/app_context.{type AppContext}
import docs/components/counter.{CounterProps, counter}
import docs/utils/common.{mist_response}
import docs/utils/csrf
import gleam/bytes_tree
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import sprocket.{component}
import sprocket/render.{render_element}
import sprocket/renderers/html.{html_renderer}

pub fn standalone(
  _req: Request(Connection),
  app_ctx: AppContext,
) -> Response(ResponseData) {
  let el = component(counter, CounterProps(initial: 100, enable_reset: False))

  let standalone_counter = render_element(el, html_renderer())

  let csrf = csrf.generate(app_ctx.secret_key_base)

  let body = "
<html>
  <head>
    <title>Standalone Counter Example - Sprocket</title>
    <meta name=\"csrf-token\" content=\"" <> csrf <> "\" />
  </head>
  <body>
    <h1>Standalone Counter Example</h1>
    <p>
      Components can be mounted to a DOM node on a separately rendered html page using JavaScript, even if the page was not initially rendered by Sprocket.
    </p>

    <p>
      For example:
    </p>
    <p>
      <code>
        <pre>
import { connect } from 'sprocket-js';

window.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document
    .querySelector('meta[name=csrf-token]')
    ?.getAttribute('content');

  if (csrfToken) {
    connect('/components/counter/connect', document.getElementById('counter'), csrfToken, {
      initialProps: { initial: '100' },
    });
  } else {
    console.error('Missing CSRF token');
  }
});
        </pre>
      </code>
    </p>

    <p>
      This example is being rendered by a Gleam webserver and therefore it can do a first-paint render of a counter component on the server, and then mount the component to the DOM node on the client.
    </p>
    <div id='counter'>
" <> standalone_counter <> "
    </div>
    <p>
      But it could also be rendered solely using JavaScript on the client without a first-paint using any other webserver or static file server.
    </p>
    <div id='no-first-paint-counter'>
    </div>
    <p>
    If you reload the page, you'll notice the second counter above is not rendered until the JavaScript has loaded which means there is a delay before the counter appears.
    If your webserver is written in Gleam you can avoid this delay by doing a first-paint render of the component on the server, but it is not required.
    </p>
    <script src=\"/standalone_counter.js\"></script>
    <p>
      <a href=\"/under-the-hood\">Return to Docs</a>
    </p>
  </body>
</html>
"

  response.new(200)
  |> response.set_body(body)
  |> response.prepend_header("content-type", "text/html")
  |> response.map(bytes_tree.from_string)
  |> mist_response()
}
