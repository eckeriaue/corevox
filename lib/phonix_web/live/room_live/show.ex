defmodule PhonixWeb.RoomLive.Show do
  use PhonixWeb, :live_view
  # alias Phonix.Calls.Room
  alias Phonix.Calls

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.call flash={@flash} current_scope={@current_scope}>
      <section class="grid grid-cols-5 h-full">
        <div class="bg-base-200 -mt-16" style="height: calc(100% + var(--spacing) * 16)">
          <div class="pt-16 h-full">
            <ul class="list text-sm text-base-content h-full overflow-y-scroll">
              <li id="me" class="list-row">
                {@current_scope.user.name}
              </li>

              <ul id="members" phx-update="stream" class="list contents">
                <%= for {id, member} <- @streams.members do %>
                  <li class="list-row opacity-40" id={id}>
                    <span class="">{member.name}</span>
                    <span class="text-xs">{member.email}</span>
                  </li>
                <% end %>
              </ul>
            </ul>
          </div>
        </div>

        <div class="col-span-4 h-full bg-base-300"></div>
      </section>
    </Layouts.call>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: current_scope}} = socket)
      when is_nil(current_scope) do
    {:ok,
     socket
     |> put_flash(:info, "Чтобы войти в комнату вы должны быть авторизованы")
     |> redirect(to: ~p"/users/register")}
  end

  def mount(params, _session, socket) do
    room_id = String.to_integer(params["id"])
    user = get_in(socket.assigns, [:current_scope, :user])

    if connected?(socket) do
      Phonix.PubSub |> Phoenix.PubSub.subscribe("call:#{Integer.to_string(room_id)}")
    end

    members =
      Calls.get_room_members(room_id)
      |> Enum.reject(fn member -> member.id == user.id end)

    case Calls.join_room(user, room_id) do
      {:error, _} ->
        {:ok,
         socket
         |> put_flash(:error, "При входе в комнату произошла ошибка")
         |> redirect(to: ~p"/rooms/#{room_id}/prepare")}

      {:ok, room_member} ->
        Phonix.PubSub |> Phoenix.PubSub.broadcast("call:#{room_id}", {:member_joined, room_id})

        {:ok,
         socket
         |> assign(:room_id, room_id)
         |> assign(:room_member, room_member)
         |> stream(:members, members)}
    end
  end

  @impl true
  def handle_info({:member_joined, room_id}, socket) do
    user = get_in(socket.assigns, [:current_scope, :user])

    members =
      Calls.get_room_members(room_id)
      |> Enum.reject(fn member -> member.id == user.id end)

    {:noreply, assign(socket, :members, members)}
  end
end
