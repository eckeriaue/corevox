defmodule Phonix.Calls do
  import Ecto.Query, warn: false
  alias Phonix.Repo
  alias Phonix.Calls.Room
  alias Phonix.Calls.RoomMember


  def list_rooms do
    Repo.all(Room)
  end

  def get_room!(id), do: Room |> Repo.get!(id)

  def create_room(attrs \\ %{}, user) do
    %Room{}
      |> Room.changeset(attrs, user)
      |> Repo.insert()
  end

  def join_room(user, room) do
    %RoomMember{}
      |> RoomMember.changeset(%{ user_id: user.id, room_id: room.id })
      |> Repo.insert(on_conflict: :nothing, conflict_target: [:room_id, :user_id])
  end

  def leave_room(user, room) do
    from(rm in RoomMember, where: rm.user_id == ^user.id and rm.room_id == ^room.id)
    |> Repo.delete_all()
  end


end
