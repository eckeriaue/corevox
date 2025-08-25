defmodule PhonixWeb.RoomLive.Index do
  use PhonixWeb, :live_view
  # alias Phonix.Accounts
  # alias Phonix.Calls
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
        <p>доступные комнаты есть, но я их не покажу</p>
      <% end %>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:rooms, [])}
  end
end
