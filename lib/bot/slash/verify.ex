defmodule AccountBot.Bot.Slash.Verify do
  @behaviour Nosedrum.ApplicationCommand

  alias AccountBot.Accounts

  # mailer regular expression from Ruby on Rails =))))
  @mail_regexp ~r/\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/i

  @impl true
  @spec description() :: String.t()
  def description, do: "Verify user information in this server"

  @impl true
  def command(interaction) do
    user = Accounts.get_unactivate_by_discord_id("#{interaction.user.id}")

    case user do
      %Accounts.User{is_activated: activation_status} when activation_status == true ->
        [content: ":fire: **You already verified !**", ephemeral?: true]

      %Accounts.User{is_activated: activation_status} when activation_status == false ->
        [
          content: ":fire: **You already request verification ! Do you want to verify again?**",
          ephemeral?: true
        ]

      nil ->
        handle_new_user_verification(interaction)
    end
  end

  @impl true
  def options do
    [
      %{
        type: :string,
        name: "name",
        required: true,
        description: "Your name"
      },
      %{
        type: :string,
        name: "email",
        required: true,
        description: "Your email address"
      },
      %{
        type: :string,
        name: "student_id",
        required: true,
        description: "Your student ID at PTIT (leave blank if you come from another college)"
      }
    ]
  end

  @impl true
  @spec type() :: :slash
  def type() do
    :slash
  end

  defp handle_new_user_verification(interaction) do
    [
      %{name: "name", value: user_name},
      %{name: "email", value: user_email},
      %{name: "student_id", value: user_student_id}
    ] = interaction.data.options

    name = user_name |> santinize_name!
    email = user_email |> santinize_email!
    student_id = user_student_id |> santinize_student_id!

    case Accounts.exists_with_email?(email) do
      true ->
        [
          content: ":x: Email **#{user_email}** already used! Please use another email.",
          ephemeral?: true
        ]

      false ->
        Accounts.create_user(%{
          name: name,
          email: email,
          student_id: student_id,
          discord_id: Integer.to_string(interaction.user.id)
        })

        [
          content:
            ":white_check_mark: **Request verification created ! Please check your email to activate your account.**",
          ephemeral?: true
        ]
    end
  catch
    x -> [content: x, ephemeral?: true]
  end

  @compile {:inline, santinize_email!: 1}
  defp santinize_email!(user_email) do
    email = String.downcase(user_email) |> String.trim()

    case email =~ @mail_regexp do
      false -> throw(":x: Invalid email address format.")
      true -> String.downcase(email)
    end
  end

  @compile {:inline, santinize_name!: 1}
  defp santinize_name!(name) do
    trimmed_name = String.trim(name)

    case trimmed_name =~ ~r/^[a-zA-Z\sÀ-ỹ]+$/ do
      false ->
        throw(":x: Invalid name.")

      true ->
        trimmed_name |> String.split() |> Stream.map(&String.capitalize/1) |> Enum.join(" ")
    end
  end

  @compile {:inline, santinize_student_id!: 1}
  defp santinize_student_id!(student_id) do
    upcased_student_id = String.upcase(student_id) |> String.trim()

    case upcased_student_id =~ ~r/[BE]\d{2}D[CV][A-Z][A-Z]\d{3}/ do
      false -> throw(":x: Invalid student ID.")
      true -> upcased_student_id
    end
  end
end
