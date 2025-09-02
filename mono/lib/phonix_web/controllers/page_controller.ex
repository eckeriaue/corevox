defmodule orvoxWeb.PageController do
  use orvoxWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
