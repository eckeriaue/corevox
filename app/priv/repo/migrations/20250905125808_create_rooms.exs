defmodule Corevox.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string, default: nil
      add :password_hash, :string, default: nil
      add :is_private, :boolean, default: false, null: false
      add :max_users, :integer
      add :owner_id, references(:users, type: :integer), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:rooms, [:owner_id])
  end
end
