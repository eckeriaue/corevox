defmodule CoreVox.Repo do
  use Ecto.Repo,
    otp_app: :corevox,
    adapter: Ecto.Adapters.Postgres
end
