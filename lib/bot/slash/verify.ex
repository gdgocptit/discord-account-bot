defmodule AccountBot.Bot.Slash.Verify do
  @behaviour Nosedrum.ApplicationCommand

  alias AccountBot.Accounts

  @impl true
  @spec description() :: String.t()
  def description, do: "Verify user information in this server"

  @impl true
  def command(interaction) do
    user = Accounts.get_unactivate_by_discord_id("#{interaction.user.id}")

    case user do
      nil ->
        interaction |> handle_new_user_verification

      _ ->
        [content: "**You already verified !** :fire:", ephemeral?: true]
    end
  end

  @impl true
  def options do
    [
      %{
        type: :string,
        name: "email",
        required: true,
        description: "Your email address"
      },
      %{
        type: :string,
        name: "student_id",
        required: false,
        description: "Your student ID at PTIT (leave blank if you come from another college)"
      }
    ]
  end

  @impl true
  def type() do
    :slash
  end

  defp handle_new_user_verification(interaction) do
  end
end
