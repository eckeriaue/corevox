defmodule CorevoxWeb.RoomChannel do
	use CorevoxWeb, :channel
	alias Corevox.Rooms
	alias CorevoxWeb.Presence
	alias Corevox.Accounts

	def join("rooms:lobby", _params, socket) do
	  rooms = Rooms.list_public_rooms()
	  {:ok, %{rooms: rooms}, socket}
	end

	def join("rooms:" <> room_id, _params, socket) do
    send(self(), :after_join)
    {:ok, %{room: nil}, socket |> assign(:room_id, room_id)}
  end

  def handle_info(:after_join, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)

    {:ok, _} = Presence.track(socket, "user:#{user.id}", %{
      joined_at: System.system_time(:second),
      id: user.id,
      name: user.name,
      email: user.email,
    })

    push(socket, "presence_state", Presence.list(socket))

    {:noreply, socket}
  end

	def handle_in("create_room", attrs, socket) do
    case attrs |> Map.merge(%{"max_users" => 12}) |> Rooms.create_room() do
      {:ok, room} ->
        payload = room |> Map.take([:id, :description, :name])
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
