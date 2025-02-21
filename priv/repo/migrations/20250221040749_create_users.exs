defmodule AccountBot.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :student_id, :string, null: true, default: nil
      add :discord_id, :string
      add :is_activated, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:users, [:email], unique: true)
    create index(:users, [:discord_id], unique: true)
    create index(:users, [:is_activated])
  end
end
