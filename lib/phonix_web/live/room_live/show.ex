defmodule PhonixWeb.RoomLive.Show do
  use PhonixWeb, :live_view

  # alias Phonix.Calls

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      room_id: {@room_id}
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
      socket
      |> assign(:room_id, params["id"])
    }
  end
end
