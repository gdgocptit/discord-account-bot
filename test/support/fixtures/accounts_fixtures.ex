defmodule AccountBot.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AccountBot.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        discord_id: "some discord_id",
        email: "some email",
        name: "some name",
        student_id: "some student_id"
      })
      |> AccountBot.Accounts.create_user()

    user
  end
end
