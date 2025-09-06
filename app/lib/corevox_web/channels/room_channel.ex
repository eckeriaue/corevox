defmodule CorevoxWeb.RoomChannel do
  use CorevoxWeb, :channel
  alias Corevox.Rooms
  alias CorevoxWeb.Presence
  alias Corevox.Accounts
  alias CorevoxWeb.Auth.Guardian

  def join("rooms:lobby", _params, socket) do
    rooms = Rooms.list_public_rooms()
    {:ok, %{rooms: rooms}, socket}
  end

  def join("rooms:" <> room_id, params, socket) do
    user_id =
      case params do
        %{"token" => token} ->
          case Guardian.decode_and_verify(token) do
            {:ok, claims} -> claims["sub"]
            {:error, _reason} -> nil
          end
      end

    if is_nil(user_id) do
      {:error, %{error: "unauthorized"}}
    else
      send(self(), :after_join)
      {:ok, socket |> assign(:room_id, room_id) |> assign(:user_id, user_id)}
    end
  end

  def handle_info(:after_join, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)

    {:ok, _} =
      Presence.track(socket, "user:#{user.id}", %{
        joined_at: DateTime.from_unix!(System.system_time(:second)) |> DateTime.to_iso8601(),
        id: user.id,
        enable_camera: false,
        enable_microphone: false,
        username: user.username,
        email: user.email
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

  def handle_in("change_user_media", %{"user_id" => user_id, "enable_microphone" => enable_microphone, "enable_camera" => enable_camera}, socket) do
    :ok = socket |> broadcast!("user_media_changed", %{user_id: user_id, enable_microphone: enable_microphone, enable_camera: enable_camera})
    {:noreply, socket}
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
