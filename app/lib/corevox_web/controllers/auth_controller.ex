defmodule CorevoxWeb.AuthController do
  use CorevoxWeb, :controller
  alias Corevox.{Accounts}
  alias CorevoxWeb.Auth.Guardian

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        conn
        |> json(%{user: %{id: user.id, email: user.email, token: token, username: user.username}})

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def sign_up(conn, %{"email" => email, "username" => username, "password" => password}) do
    case Accounts.register_user(%{email: email, username: username, password: password}) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        conn
        |> json(%{user: %{id: user.id, email: user.email, token: token, username: user.username}})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors:
            Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
        })
    end
  end

  def sign_out(conn, _params) do
    conn
    |> json(%{message: "Signed out successfully"})
  end

end
