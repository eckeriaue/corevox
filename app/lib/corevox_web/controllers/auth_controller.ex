defmodule CorevoxWeb.AuthController do
  use CorevoxWeb, :controller
  alias Corevox.{Accounts}
  alias CorevoxWeb.Auth.Guardian

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        conn
        |> put_resp_cookie(
          "access_token",
          token,
          http_only: true,
          secure: Mix.env() == :prod,
          max_age: 60 * 60 * 24 * 7 # 7 дней
        )
        # |> put_status(:ok)
        |> json(%{user: %{id: user.id, email: user.email}})

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
        |> put_resp_cookie(
          "access_token",
          token,
          http_only: true,
          secure: Mix.env() == :prod,
          max_age: 60 * 60 * 24 * 7
        )
        |> json(%{user: %{id: user.id, email: user.email, username: user.username}})

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
    |> delete_resp_cookie("access_token")
    |> json(%{message: "Signed out successfully"})
  end

  # def options(conn, _params) do
  #   conn
  #   |> put_status(200)
  #   |> text("")
  # end

end
