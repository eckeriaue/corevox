defmodule CorevoxWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "rooms:*", CorevoxWeb.RoomChannel
  channel "register:formvalidation", CorevoxWeb.RegisterChannel
  channel "login:formvalidation", CorevoxWeb.LoginChannel

  def connect(%{"token" => token}, socket, _connect_info) do
    case CorevoxWeb.Auth.Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        {:ok, assign(socket, :user_id, claims["sub"])}
      {:error, _reason} ->
        {:ok, assign(socket, :user_id, nil)}
    end
  end

  def connect(_params, socket, _connect_info) do
    {:ok, assign(socket, :user_id, nil)}
  end

  def connect(%{"token" => token}, socket, _connect_info) do
    case CorevoxWeb.Auth.Guardian.resource_from_claims(token) do
      {:ok, user} ->
        {:ok, assign(socket, :user_id, user.id)}
      {:error, _reason} ->
        {:ok, assign(socket, :user_id, nil)}
    end
  end

  def id(%{assigns: %{user_id: nil}}), do: nil
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
