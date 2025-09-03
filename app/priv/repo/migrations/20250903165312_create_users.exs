defmodule Corevox.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :username, :string
      add :password_hash, :string
      add :confirmed_at, :utc_datetime, default: nil

      timestamps(type: :utc_datetime)
    end
  end
end
