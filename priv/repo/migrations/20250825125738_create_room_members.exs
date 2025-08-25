defmodule Phonix.Repo.Migrations.CreateRoomMembers do
  use Ecto.Migration

  def change do
    create table(:room_members) do
      add :role, :string
      add :room_id, references(:rooms, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
