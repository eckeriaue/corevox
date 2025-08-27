defmodule PhonixWeb.RoomLive.Show do
  use PhonixWeb, :live_view
  # alias Phonix.Calls.Room
  alias Phonix.Calls


  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.call flash={@flash} current_scope={@current_scope}>
      <section class="grid grid-cols-5 h-full">
        <div class="border-r h-full border-base-100">
          <ul class="list text-sm text-base-content">
            <li class="list-row">
              {@current_scope.user.email}
            </li>

            <%= for member <- @members do %>
              <li class="list-row">
                {member.email}
              </li>
            <% end %>
          </ul>
        </div>

        <div class="col-span-4 h-full bg-base-300">
        </div>
      </section>
    </Layouts.call>
    """
  end

  @impl true
  def mount(params, _session, socket) do


    room_id = String.to_integer(params["id"])

    if connected?(socket) do
      Phonix.PubSub |> Phoenix.PubSub.subscribe("room:#{Integer.to_string(room_id)}")
    end

    case user = get_in(socket.assigns, [:current_scope, :user]) do
      nil ->
        {:ok,
          socket
            |> put_flash(:info, "Чтобы войти в комнату вы должны быть зарегестрированы")
            |> redirect(to: ~p"/users/register")}

      %{} ->
        members = Calls.get_room_members(room_id)
          |> Enum.reject(fn member -> member.id == user.id end)

        case Calls.join_room(user, room_id) do
          {:error, _} ->
            {:ok,
              socket
                |> put_flash(:error, "При входе в комнату произошла ошибка")
                |> redirect(to: ~p"/rooms/#{room_id}/prepare")}

          {:ok, room_member} ->
            Phonix.PubSub |> Phoenix.PubSub.broadcast("room:#{room_id}", {:member_joined, room_id})
            {:ok,
              socket
                |> assign(:room_id, room_id)
                |> assign(:room_member, room_member)
                |> assign(:members, members)}

        end
    end
  end

  @impl true
  def handle_info({:member_joined, room_id}, socket) do
    user = get_in(socket.assigns, [:current_scope, :user])
    members = Calls.get_room_members(room_id)
      |> Enum.reject(fn member -> member.id == user.id end)
    {:noreply, assign(socket, :members, members)}
  end
end
