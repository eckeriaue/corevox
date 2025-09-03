defmodule CorevoxWeb.RoomChannel do
	use CorevoxWeb, :channel
	def join("room:lobby", _params, socket) do
		{:ok, socket}
	end

	def handle_in("new_msg", %{"body" => body}, socket) do
		broadcast(socket, "new_msg", %{body: body})
		{:noreply, socket}
	end
end
