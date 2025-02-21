defmodule AccountBot.Repo do
  use Ecto.Repo,
    otp_app: :account_bot,
    adapter: Ecto.Adapters.Postgres
end
