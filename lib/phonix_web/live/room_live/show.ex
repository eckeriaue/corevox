defmodule PhonixWeb.RoomLive.Show do
  use PhonixWeb, :live_view

  # alias Phonix.Calls

  @impl true
  def render(assigns) do
    ~H"""
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
