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

  def sign_up(conn, %{"email" => email, "username" => username, "password" => password}) do
    case Corevox.Accounts.register_user(%{email: email, username: username, password: password}) do
      {:ok, user} ->
        {:ok, token, _claims} = CorevoxWeb.Auth.Guardian.encode_and_sign(user)
        json(conn, %{token: token, user: %{id: user.id, email: user.email, username: user.username}})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
    end
  end

end
