defmodule PhonixWeb.RoomLive.Form do
  use PhonixWeb, :live_view
  alias Phonix.Accounts

  @impl true
  def render(assigns) do
    ~H"""

    <Layouts.app flash={@flash} current_scope={@current_scope}>
      Комната
    </Layouts.app>
    """
  end


  @impl true
  def mount(_params, session, socket) do
    {:ok, socket
    }
  end
end
