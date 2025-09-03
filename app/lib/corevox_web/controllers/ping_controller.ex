defmodule CorevoxWeb.PingController do
  use CorevoxWeb, :controller

  def ping(conn, _params) do
    conn |> json(%{response: "pong"})
  end
end
