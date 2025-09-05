defmodule CorevoxWeb.RoomChannel do
	use CorevoxWeb, :channel
	alias Corevox.Rooms


	def join("rooms:lobby", _params, socket) do
	  rooms = Rooms.list_public_rooms()
	  {:ok, %{rooms: rooms}, socket}
	end


	def handle_in("create_room", attrs, socket) do
    case attrs |> Map.merge(%{"max_users" => 12}) |> Rooms.create_room() do
      {:ok, room} ->
        payload = Map.take(room, [:id, :description, :name])
        if not room.is_private do
          :ok = socket |> broadcast!("room_created", %{room: payload})
        end
        {:reply, {:ok, payload}, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset_errors(changeset)}}, socket}
    end
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
