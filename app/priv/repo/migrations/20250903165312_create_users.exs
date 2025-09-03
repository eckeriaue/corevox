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
    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
