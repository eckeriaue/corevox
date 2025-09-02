defmodule orvoxWeb.Presence do
  use Phoenix.Presence,
    otp_app: :orvox,
    pubsub_server: orvox.PubSub
end
