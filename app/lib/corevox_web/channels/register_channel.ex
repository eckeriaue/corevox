defmodule CorevoxWeb.RegisterChannel do
	use CorevoxWeb, :channel
	alias Corevox.Accounts


	def join("register:formvalidation", _params, socket) do
		{:ok, socket}
	end

	def handle_in("check_username", %{"value" => username}, socket) do
    unique = !Accounts.user_exists_by_username?(username)
    send_validate_reply(socket, %{unique: unique})
  end

  def handle_in("check_email", %{"value" => email}, socket) do
    unique = !Accounts.user_exists_by_email?(email)
    send_validate_reply(socket, %{unique: unique})
  end

  defp send_validate_reply(socket, payload) do
    {:reply, {:ok, payload}, socket}
  end
end
