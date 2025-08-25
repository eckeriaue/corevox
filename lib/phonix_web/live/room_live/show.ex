defmodule PhonixWeb.RoomLive.Show do
  use PhonixWeb, :live_view

  # alias Phonix.Calls

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      room
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
