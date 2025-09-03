defmodule CorevoxWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :corevox,
    error_handler: CorevoxWeb.Auth.ErrorHandler,
    module: CorevoxWeb.Auth.Guardian

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
