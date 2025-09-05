defmodule Corevox.Rooms do
  import Ecto.Query, warn: false
  alias Corevox.Repo
  alias Corevox.Rooms.Room

  def list_public_rooms do
    query =
      from r in Room,
        where: r.is_private == false,
        order_by: [desc: r.inserted_at]

    Repo.all(query)
  end

  def get_room!(id), do: Repo.get!(Room, id)
  def create_room(attrs), do: %Room{} |> Room.changeset(attrs) |> Repo.insert()
end
