defmodule PhonixWeb.RoomLive.Show do
  use PhonixWeb, :live_view
  alias Phonix.Calls.Room
  alias Phonix.Calls

  # alias Phonix.Calls

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.call flash={@flash} current_scope={@current_scope}>
      room_id: {@room_id}
    </Layouts.call>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    id = params["id"]

    IO.inspect(Calls.join_room(socket.assigns.current_scope.user, String.to_integer(id)))
    case Calls.join_room(socket.assigns.current_scope.user, String.to_integer(id)) do
      {:error, _} ->
        {:ok,
          socket
            |> put_flash(:error, "При входе в комнату произошла ошибка")
            |> redirect(to: ~p"/rooms/#{id}/prepare")
          }
      {:ok, room_member} ->
        {:ok,
          socket
            |> assign(:room_id, id)
        }
    end
  end
end
