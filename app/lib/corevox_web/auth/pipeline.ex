defmodule CorevoxWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :corevox,
    module: CorevoxWeb.Auth.Guardian,
    error_handler: CorevoxWeb.Auth.ErrorHandler

  plug Guardian.Plug.VerifyCookie, key: "access_token"
  plug Guardian.Plug.LoadResource
  plug Guardian.Plug.EnsureAuthenticated
end
