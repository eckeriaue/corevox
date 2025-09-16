defmodule CorevoxWeb.Presence do
  use Phoenix.Presence,
    otp_app: :corevox,
    pubsub_server: Corevox.PubSub
end
