defmodule CorevoxWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :corevox
  # use Phoenix.Presence, otp_app: :corevox, pubsub_server: Corevox.PubSub

  plug Corsica,
    origins: ["http://localhost:4321"], # Замените на актуальный домен фронтенда
    allow_methods: ["GET", "POST", "OPTIONS", "PUT", "DELETE", "PATCH", "HEAD", "CONNECT", "TRACE"],
    allow_headers: ["content-type", "authorization"],
    allow_credentials: true,
    max_age: 3600,
    send_preflight_response?: true

  socket "/socket", CorevoxWeb.UserSocket,
    websocket: true,
    longpoll: false

  @session_options [
    store: :cookie,
    key: "_corevox_key",
    signing_salt: "x2axwk7a",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :corevox,
    gzip: not code_reloading?,
    only: CorevoxWeb.static_paths()

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :corevox
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug CorevoxWeb.Router
end
