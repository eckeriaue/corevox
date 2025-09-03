defmodule CorevoxWeb.UserController do
  use CorevoxWeb, :controller

  def me(conn, _params) do
    token = Guardian.Plug.current_token(conn)
    IO.inspect(token, label: "Current Token")
    user = Guardian.Plug.current_resource(conn)
    IO.inspect(user, label: "Current User")
    json(conn, %{id: user.id, email: user.email})
  end
end
