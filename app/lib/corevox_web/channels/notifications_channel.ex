defmodule CorevoxWeb.NotificationsChannel do
  use CorevoxWeb, :channel

  def join("notifications:news", _params, socket) do
    {:ok, socket}
  end


  def handle_in("send", %{"message" => message, "type" => type}, socket)
  when
    type == "info" or
    type == "error" or
    type == "warning" or
    type == "success"
  do
    broadcast!(socket, "notification", %{message: message, type: type})
    {:noreply, socket}
  end
end
