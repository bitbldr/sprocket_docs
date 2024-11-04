FROM ghcr.io/gleam-lang/gleam:v1.5.1-erlang-alpine as builder

RUN apk update && apk add --no-cache build-base python3
RUN apk add --update nodejs npm elixir

RUN npm install -g yarn typescript ts-node

WORKDIR /build

# copy source files
COPY package.json yarn.lock ./

# install node deps
RUN yarn install

# copy source files
COPY . .

# install gleam deps
RUN gleam deps download

# build gleam app
RUN yarn build

# # build release
RUN gleam export erlang-shipment

RUN mv build/erlang-shipment /app

# FROM erlang:24.0.1-alpine
FROM ghcr.io/gleam-lang/gleam:v1.5.1-erlang-alpine

WORKDIR /app
RUN chown nobody /app

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app /app

USER nobody

EXPOSE 3000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]