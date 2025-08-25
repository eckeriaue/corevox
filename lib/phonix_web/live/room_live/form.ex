defmodule PhonixWeb.RoomLive.Form do
  use PhonixWeb, :live_view
  # alias Phonix.Accounts
  alias Phonix.Calls
  alias Phonix.Calls.Room

  @impl true
  def mount(_params, _session, socket) do
    changeset = Calls.change_room(%Room{})

    {:ok,
     socket
     |> assign(:changeset, changeset)
     |> assign(:disabled, true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.form
        :let={f}
        for={@changeset}
        phx-submit="save"
        phx-change="validate"
      >
        <.header>Создание комнаты</.header>
        <.input
          label="Название комнаты"
          field={f[:name]}
        />

        <.input
          label="Пароль для входа в комнату (необязательно)"
          field={f[:password]}
        />
        <.button type="submit" disabled={@disabled}>Создать</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("save", %{"room" => %{ "name" => name, "password" => password }}, socket) do
    case Calls.create_room(%{ "name" => name, "password" => password }, socket.assigns.current_scope) do
      {:ok, room} ->
        {:noreply, socket |> put_flash(:info, "Комната создана") |> push_redirect(to: ~p"/rooms/#{room.id}")}
      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "При создании комнаты произошла ошибка")}
    end
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset =
      %Room{}
      |> Calls.change_room(room_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:disabled, !changeset.valid?)}
  end
end
