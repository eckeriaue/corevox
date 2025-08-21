defmodule PhonixWeb.LivePageHome do
  use PhonixWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    """
  end

  def handle_event("go", _unsigned_params, socket) do
    {:noreply, socket}
  end

end
