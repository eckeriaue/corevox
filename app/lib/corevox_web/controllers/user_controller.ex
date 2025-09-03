defmodule CorevoxWeb.UserController do
  use CorevoxWeb, :controller

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    json(conn, %{id: user.id, email: user.email})
  end
end
