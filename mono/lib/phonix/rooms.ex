defmodule orvox.Rooms do
  import Ecto.Query, warn: false
  alias orvox.Calls.Room
  alias orvox.Repo

  def list_rooms do
    Repo.all(Room)
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

end
