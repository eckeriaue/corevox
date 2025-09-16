FROM elixir:1.18.0-alpine AS builder

WORKDIR /app

RUN apk add --no-cache \
    git \
    build-base \
    nodejs \
    npm

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

COPY . .

RUN mix compile
RUN npm install --prefix assets
RUN npm run deploy --prefix assets
RUN mix assets.deploy
RUN mix release

FROM elixir:1.18.0-alpine

RUN apk add --no-cache \
    postgresql-client

WORKDIR /app

COPY --from=builder /app/_build/prod/rel /app/rel

EXPOSE 4000

USER nobody

CMD ["/app/rel/corevox/bin/corevox", "start"]
