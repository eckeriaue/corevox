defmodule CorevoxWeb.RoomsChannel do
	use CorevoxWeb, :channel

	def join("rooms", _params, socket) do
		{:ok, socket}
	end

	def handle_in("create_room", attrs, socket) do
		{:noreply, socket}
	end

end
