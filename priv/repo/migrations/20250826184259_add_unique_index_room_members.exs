defmodule Phonix.Repo.Migrations.AddUniqueIndexRoomMembers do
  use Ecto.Migration

  def change do
    create unique_index(:room_members, [:room_id, :user_id])
  end
end
