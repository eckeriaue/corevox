defmodule Phonix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhonixWeb.Telemetry,
      Phonix.Repo,
      {DNSCluster, query: Application.get_env(:phonix, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Phonix.PubSub},
      PhonixWeb.Presence,
      # Start a worker by calling: Phonix.Worker.start_link(arg)
      # {Phonix.Worker, arg},
      # Start to serve requests, typically the last entry
      PhonixWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phonix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhonixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
