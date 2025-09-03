defmodule CorevoxWeb.UserController do
  use CorevoxWeb, :controller

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    json(conn, %{id: user.id, username: user.username, confirmed_at: user.confirmed_at, email: user.email})
  end
end
