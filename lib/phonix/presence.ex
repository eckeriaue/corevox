defmodule PhonixWeb.Presence do
  use Phoenix.Presence,
    otp_app: :phonix,
    pubsub_server: Phonix.PubSub
end
