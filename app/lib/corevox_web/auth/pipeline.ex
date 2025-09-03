defmodule CorevoxWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :corevox,
    module: CorevoxWeb.Auth.Guardian,
    error_handler: CorevoxWeb.Auth.ErrorHandler

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
end
