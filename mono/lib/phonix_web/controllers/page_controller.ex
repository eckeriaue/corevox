defmodule PhonixWeb.PageController do
  use PhonixWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
