defmodule PhonixWeb.RoomLive.Index do
  use PhonixWeb, :live_view
  alias Phonix.Calls
  # alias Phonix.Accounts
  # on_mount {PhonixWeb.UserAuth, :require_sudo_mode}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex justify-between">
        <.header>
          Список доступных комнат
        </.header>
        <.button href={~p"/rooms/new"} class="btn btn-primary">
          Создать <span aria-hidden="true">&rarr;</span>
        </.button>
      </div>

      <%= if Enum.empty?(@rooms) do %>
        <p>Доступных комнат пока нет</p>
      <% else %>
        <ul class="list bg-base-100 rounded-box shadow-md">
        <%= for room <- @rooms do %>
          <li class="list-row">
            <div><img class="size-10 rounded-box" src={"https://robohash.org/room-#{room.id}-generated"}/></div>
            <div>
              <div>{room.name}</div>
              <div class="text-xs font-semibold opacity-60">Без описания</div>
            </div>
            <div class="tooltip" data-tip="Войти в комнату">
              <.button href={~p"/rooms/#{room.id}"} class="btn btn-square btn-ghost" >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15M12 9l3 3m0 0-3 3m3-3H2.25" />
                </svg>
              </.button>
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
    rooms = Calls.list_rooms()
    {:ok, socket |> assign(:rooms, rooms)}
  end
end
