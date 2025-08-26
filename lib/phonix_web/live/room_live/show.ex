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

    room_id = params["id"]
    user = get_in(socket.assigns, [:current_scope, :user])

    # with nil <- user do

    # end

    if user == nil do
      {:ok,
        socket
          |> put_flash(:info, "Чтобы войти в комнату вы должны быть зарегестрированы")
          |> redirect(to: ~p"/users/register")
        }
    else
      members = Calls.get_room_members(String.to_integer(room_id)) |> Enum.reject(fn member -> member.id == user.id end)

      case user |> Calls.join_room(String.to_integer(room_id)) do
        {:error, _} ->
          {:ok,
            socket
              |> put_flash(:error, "При входе в комнату произошла ошибка")
              |> redirect(to: ~p"/rooms/#{room_id}/prepare")
            }
        {:ok, room_member} ->
          {:ok,
            socket
              |> assign(:room_id, room_id)
              |> assign(:room_member, room_member)
          }
      end
    end
  end
end
