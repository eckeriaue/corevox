defmodule CorevoxWeb.AuthChannel do

  def join("auth", _params, socket) do
    {:ok, socket}
  end

end
