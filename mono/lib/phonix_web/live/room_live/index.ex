defmodule orvoxWeb.RoomLive.Index do
  alias orvox.Rooms
  use orvoxWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex justify-between">
        <.header>
          Список доступных комнат
        </.header>
        <%= if @current_scope do %>
          <.button href={~p"/rooms/new"} class="btn btn-primary">
            Создать <span aria-hidden="true">&rarr;</span>
          </.button>
        <% end %>
      </div>

      <%= if Enum.empty?(@rooms) do %>
        <p>Доступных комнат пока нет</p>
      <% else %>
        <ul class="list bg-base-100 rounded-box shadow-md">
          <%= for room <- @rooms do %>
            <li class="list-row">
              <div>
                <img
                  class="size-10 rounded-box"
                  src={"https://robohash.org/room-#{room.id}-generated"}
                />
              </div>
              <div>
                <div>{room.name}</div>
                <div class="text-xs font-semibold opacity-60">
                  {room.description || "Без описания"}
                </div>
              </div>
              <div class="tooltip" data-tip="Войти в комнату">
                <%= if @current_scope do %>
                  <.button href={~p"/rooms/#{room.id}/prepare"} class="btn btn-square btn-ghost">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      class="size-6"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15M12 9l3 3m0 0-3 3m3-3H2.25"
                      />
                    </svg>
                  </.button>
                <% end %>
              </div>
            </li>
          <% end %>
        </ul>
      <% end %>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    rooms = Rooms.list_rooms()
    {:ok, socket |> assign(:rooms, rooms)}
  end
end
