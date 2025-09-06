defmodule Corevox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CorevoxWeb.Telemetry,
      Corevox.Repo,
      {DNSCluster, query: Application.get_env(:corevox, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Corevox.PubSub},
      # Start a worker by calling: Corevox.Worker.start_link(arg)
      # {Corevox.Worker, arg},
      # Start to serve requests, typically the last entry
      CorevoxWeb.Endpoint,
      CorevoxWeb.Presence,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Corevox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CorevoxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
