defmodule AccountBot.Bot.Slash.Ping do
  @behaviour Nosedrum.ApplicationCommand

  import Nostrum.Struct.Embed

  alias Nostrum.Struct.User

  @impl true
  @spec description() :: String.t()
  def description, do: "Get bot latency, information about bot"

  @impl true
  def command(interaction) do
    avatar_url = interaction.user |> User.avatar_url("png")

    embed =
      %Nostrum.Struct.Embed{}
      |> put_author(interaction.member.nick, avatar_url, avatar_url)
      |> put_thumbnail(avatar_url)
      |> put_title("Pong!")
      |> put_color(0xFD4F00)
      |> put_footer("GDG on Campus - PTIT: Account Bot")
      |> put_field("Latency", "`#{get_ping()}ms`", true)
      |> put_field("Version", "`#{Application.spec(:account_bot, :vsn)}`", false)
      |> put_field("Elixir Version", "`#{Application.spec(:elixir, :vsn)}`", false)
      |> put_field("Phoenix Version", "`#{Application.spec(:phoenix, :vsn)}`", false)

    [embeds: [embed]]
  end

  @impl true
  def type() do
    :slash
  end

  defp get_ping do
    latency = Nostrum.Util.get_all_shard_latencies() |> Map.values()

    round(Enum.sum(latency) / length(latency))
  end
end
