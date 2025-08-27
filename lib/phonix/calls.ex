defmodule Phonix.Calls do
  import Ecto.Query, warn: false
  alias Phonix.Repo
  alias Phonix.Calls.Room
  alias Phonix.Accounts.User
  alias Phonix.Calls.RoomMember

  def list_rooms do
    Repo.all(Room)
  end

  def get_room!(id), do: Room |> Repo.get!(id)

  def get_room_members(id) do
    query =
      from room_members in RoomMember,
        join: user in User,
        on: user.id == room_members.user_id,
        where: room_members.room_id == ^id,
        select: user

    Repo.all(query)
  end

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

    with_hashed_password_attrs =
      attrs
      |> Map.take(["name", "description"])
      |> Map.merge(if password_hash, do: %{"password_hash" => password_hash}, else: %{})

    %Room{}
    |> Room.changeset(with_hashed_password_attrs, user)
    |> Repo.insert()
  end

  def join_room(user, %Room{id: room_id}), do: join_room(user, room_id)

  def join_room(user, room_id) when is_integer(room_id) do
    %RoomMember{}
    |> RoomMember.changeset(%{user_id: user.id, role: "member", room_id: room_id})
    |> Repo.insert(on_conflict: :nothing, conflict_target: [:room_id, :user_id])
  end


  def leave_room(user, room_id) do
    from(rm in RoomMember, where: rm.user_id == ^user.id and rm.room_id == ^room_id)
    |> Repo.delete_all()
  end
end
