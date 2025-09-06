defmodule CorevoxWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  ## Channels
  channel "rooms:*", CorevoxWeb.RoomChannel
  channel "notifications:*", CorevoxWeb.NotificationsChannel
  channel "register:formvalidation", CorevoxWeb.RegisterChannel
  channel "login:formvalidation", CorevoxWeb.LoginChannel

  def connect(%{"token" => token}, socket, _connect_info) do
    case CorevoxWeb.Auth.Guardian.resource_from_claims(token) do
      {:ok, user} ->
        Logger.debug("User connected with ID: #{user.id}")
        {:ok, assign(socket, :user_id, user.id)}
      {:error, reason} ->
        Logger.warn("Failed to authenticate user: #{inspect(reason)}")
        {:ok, assign(socket, :user_id, nil)}
    end
  end

  def connect(_params, socket, _connect_info) do
    {:ok, assign(socket, :user_id, nil)}
  end

  def id(%{assigns: %{user_id: user_id}}) when not is_nil(user_id), do: "user_socket:#{user_id}"
  def id(_socket), do: nil

end
