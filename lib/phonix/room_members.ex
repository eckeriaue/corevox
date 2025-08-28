defmodule Phonix.RoomMembers do
  import Ecto.Query, warn: false
  alias Phonix.Repo
  alias Phonix.Calls.RoomMember

  def get_by_id!(id) do
    RoomMember |> Repo.get!(id)
  end

  def get_by_user_id!(user_id) do
    RoomMember |> Repo.get_by!(user_id: user_id)
  end

  def get_room_members(room_id) do
    from(room_member in RoomMember,
      where: room_member.room_id == ^room_id,
      preload: [:user]
    )
    |> Repo.all()
  end


end
