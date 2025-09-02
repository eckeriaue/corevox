defmodule Phonix.Repo do
  use Ecto.Repo,
    otp_app: :phonix,
    adapter: Ecto.Adapters.Postgres
end
