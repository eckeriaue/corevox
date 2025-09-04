defmodule CorevoxWeb.RegisterChannel do
	use CorevoxWeb, :channel
	alias Corevox.Accounts
	alias Corevox.Accounts.User
	alias CorevoxWeb.Auth.Guardian


	def join("register:formvalidation", _params, socket) do
		{:ok, socket}
	end

	def handle_in("register_me", %{"username" => username, "email" => email, "password" => password, "confirm_password" => _confirm_password}, socket) do
		case Accounts.register_user(%{"username" => username, "email" => email, "password" => password}) do
			{:ok, user} ->
  			{:ok, token, _claims} = Guardian.encode_and_sign(user)
  			{:reply, {:ok, %{token: token, user: user |> Map.take([:id, :username, :email])}}, socket}
			changeset ->
				{:reply, {:error, changeset}, socket}
		end
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
