defmodule CorevoxWeb.AuthController do
  use CorevoxWeb, :controller
  alias Corevox.{Accounts}
  alias CorevoxWeb.Auth.Guardian

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        json(conn, %{token: token, user: %{id: user.id, email: user.email}})
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end
end
