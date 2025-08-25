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
        for={@changeset.changes}
        phx-submit="save"
        phx-change="validate"
      >
        <.header>Создание комнаты</.header>
        <.input
          label="Название комнаты"
          field={f[:name]}
          value={@changeset.changes[:name] || ~c""}
        />

        <.input
          label="Пароль для входа в комнату (необязательно)"
          field={f[:password]}
          value={@changeset.changes[:password] || ~c""}
        />
        <.button type="submit" disabled={@disabled}>Создать</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("save", %{"name" => name, "password" => password}, socket) do
    {:noreply, socket |> assign(:name, name) |> assign(:password, password)}
  end

  @impl true
  def handle_event("validate", room_params, socket) do
    changeset =
      %Room{}
      |> Calls.change_room(room_params)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:disabled, !Enum.empty?(changeset.errors))}
  end
end
