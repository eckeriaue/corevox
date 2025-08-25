defmodule Phonix.Calls do
  import Ecto.Query, warn: false
  alias Phonix.Repo
  alias Phonix.Calls.Room
  alias Phonix.Calls.RoomMember

  def list_rooms do
    Repo.all(Room)
  end

  def get_room!(id), do: Room |> Repo.get!(id)

  def change_room(room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def create_room(attrs \\ %{}, user) do
    password_hash =
      case Map.get(attrs, "password") do
        nil -> nil
        "" -> nil
        password -> Bcrypt.hash_pwd_salt(password)
      end

    with_hashed_password_attrs = attrs
      |> Map.take(["name", "description"])
      |> Map.merge(if password_hash, do: %{"password_hash" => password_hash}, else: %{})

    %Room{}
    |> Room.changeset(with_hashed_password_attrs, user)
    |> Repo.insert()
  end

  def join_room(user, room) do
    %RoomMember{}
    |> RoomMember.changeset(%{user_id: user.id, room_id: room.id})
    |> Repo.insert(on_conflict: :nothing, conflict_target: [:room_id, :user_id])
  end

  def leave_room(user, room) do
    from(rm in RoomMember, where: rm.user_id == ^user.id and rm.room_id == ^room.id)
    |> Repo.delete_all()
  end
end
