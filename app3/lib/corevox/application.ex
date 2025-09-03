defmodule CoreVox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CoreVoxWeb.Telemetry,
      CoreVox.Repo,
      {DNSCluster, query: Application.get_env(:corevox, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CoreVox.PubSub},
      # Start a worker by calling: CoreVox.Worker.start_link(arg)
      # {CoreVox.Worker, arg},
      # Start to serve requests, typically the last entry
      CoreVoxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CoreVox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CoreVoxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
