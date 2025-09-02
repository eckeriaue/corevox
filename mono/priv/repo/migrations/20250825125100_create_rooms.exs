defmodule Phonix.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :password_hash, :string
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
