defmodule AccountBot.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :email, :string
    field :student_id, :string
    field :discord_id, :string
    field :is_activated, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :student_id, :discord_id, :is_activated])
    |> validate_required([:name, :email, :student_id, :discord_id])
  end
end
