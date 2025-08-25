defmodule PhonixWeb.RoomLive.Index do
  use PhonixWeb, :live_view
  alias Phonix.Accounts

  # on_mount {PhonixWeb.UserAuth, :require_sudo_mode}

  # alias Phonix.Calls

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
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    current_scope =
      case session["user_token"] do
        nil -> nil
        token -> case Accounts.get_user_by_session_token(token) do
            {user, _auth_time} -> %{user: user}
            _ -> nil
          end
      end

    {:ok, socket
      |> assign(:current_scope, current_scope)
      |> assign(:rooms, [])
    }
  end


end
