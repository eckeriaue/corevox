defmodule Corevox.Accounts do
  import Ecto.Query, warn: false
  alias Corevox.Repo
  alias Corevox.Accounts.User
  alias Bcrypt

  # Поиск юзера по email
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_user!(id), do: Repo.get!(User, id)


  # Аутентификация
  def authenticate_user(email, password) do
    case get_user_by_email(email) do
      nil ->
        # нет такого юзера
        {:error, :invalid_credentials}

      %User{} = user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end


end
