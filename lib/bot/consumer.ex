defmodule AccountBot.Bot.Consumer do
  @behaviour Nostrum.Consumer

  require Logger

  def handle_event({:READY, _ready, _ws_state}) do
    slash_commands = [
      Nosedrum.Storage.Dispatcher.add_command(
        "ping",
        AccountBot.Bot.Slash.Ping,
        Dotenv.get("GUILD_ID")
      ),
      Nosedrum.Storage.Dispatcher.add_command(
        "verify",
        AccountBot.Bot.Slash.Verify,
        Dotenv.get("GUILD_ID")
      )
    ]

    slash_commands |> Enum.each(&ensure_slash_command!/1)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) when interaction.type == 2 do
    Nosedrum.Storage.Dispatcher.handle_interaction(interaction)
  end

  def handle_event(_), do: :noop

  defp ensure_slash_command!({:ok, command}) do
    Logger.info("registered \"#{command.name}\" slash command")
  end

  defp ensure_slash_command!(e) do
    Logger.error("failed to register slash command: #{inspect(e)}")
  end
end
