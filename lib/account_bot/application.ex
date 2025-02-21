defmodule AccountBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    unless Mix.env() == :prod do
      Dotenv.load()
      Mix.Task.run("loadconfig")
    end

    bot_options = %{
      consumer: AccountBot.Bot.Consumer,
      intents: :all,
      wrapped_token: fn -> Dotenv.get("DISCORD_BOT_TOKEN") end
    }

    children = [
      AccountBotWeb.Telemetry,
      AccountBot.Repo,
      {DNSCluster, query: Application.get_env(:account_bot, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AccountBot.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AccountBot.Finch},
      # Start a worker by calling: AccountBot.Worker.start_link(arg)
      # {AccountBot.Worker, arg},
      # Start to serve requests, typically the last entry
      AccountBotWeb.Endpoint,
      {Nosedrum.Storage.Dispatcher, name: Nosedrum.Storage.Dispatcher},
      {Nostrum.Bot, bot_options}
    ]

    Application.put_env(:elixir, :ansi_enabled, true)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AccountBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AccountBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
