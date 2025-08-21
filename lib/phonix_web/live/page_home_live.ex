defmodule PhonixWeb.LivePageHome do
  use PhonixWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div>
        <.input name="test" type="text" value="" />
      </div>


      <.list>
        <:item title="Title">test</:item>
        <:item title="Views">test2</:item>
      </.list>


      <.button>Send!</.button>
      <.button phx-click="go" variant="primary">Send!</.button>
      <.button navigate={~p"/"}>Home</.button>
      <.flash kind={:info} phx-mounted={show("#flash")}>testme</.flash>
    """
  end

end
