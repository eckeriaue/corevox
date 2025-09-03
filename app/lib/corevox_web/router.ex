defmodule CorevoxWeb.Router do
  use CorevoxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/api/v1", CorevoxWeb do
    pipe_through :api


    get "/ping", PingController, :ping

    post "/auth/sign-in", AuthController, :sign_in
    post "/auth/sign-up", AuthController, :sign_up
    post "/auth/sign-out", AuthController, :sign_out

    scope "/" do
      pipe_through CorevoxWeb.Auth.Pipeline

      get "/me", UserController, :me
    end
  end

  if Application.compile_env(:corevox, :dev_routes) do
    import Phoenix.LiveDashboard.Router
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: CorevoxWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
