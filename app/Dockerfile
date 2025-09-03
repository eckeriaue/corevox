# Build stage
FROM elixir:1.18-alpine AS builder

RUN apk add --no-cache \
    erlang-os-mon \
    nodejs \
    npm \
    postgresql-client

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./

RUN mix deps.get --only prod

COPY . .

ENV MIX_ENV=prod

RUN mix deps.compile && \
    mix compile && \
    mix assets.deploy && \
    mix release

# Runtime stage
FROM elixir:1.18-alpine

RUN apk add --no-cache \
    erlang-os-mon \
    postgresql-client

WORKDIR /app

RUN adduser -D -h /app corevox

COPY --from=builder /app/_build/prod/rel/corevox /app

USER corevox

EXPOSE 4000

CMD ["/app/bin/server"]
