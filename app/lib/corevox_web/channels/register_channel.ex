defmodule CorevoxWeb.RegisterChannel do
	use CorevoxWeb, :channel
	def join("register:form", _params, socket) do
		{:ok, socket}
	end
end
