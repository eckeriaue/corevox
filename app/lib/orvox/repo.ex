defmodule Orvox.Repo do
  use Ecto.Repo,
    otp_app: :orvox,
    adapter: Ecto.Adapters.Postgres
end
