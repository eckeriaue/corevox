defmodule CorevoxWeb.LoginChannel do
  use CorevoxWeb, :channel
  alias Corevox.Accounts
  alias CorevoxWeb.Auth.Guardian

  def join("login:formvalidation", _params, socket) do
    {:ok, socket}
  end

  def handle_in("has_email", %{"value" => email}, socket) do
    has_user = Accounts.user_exists_by_email?(email)
    {:reply, {:ok, %{has_user: has_user}}, socket}
  end

  def handle_in(
        "login",
        %{"email" => email, "password" => password, "remember_me" => _remember_me},
        socket
      ) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        {:reply, {:ok, %{token: token, user: user |> Map.take([:id, :username, :email])}}, socket}

      {:error, :invalid_credentials} ->
        {:reply, {:error, %{error: "Invalid email or password"}}, socket}
    end
  end
end
