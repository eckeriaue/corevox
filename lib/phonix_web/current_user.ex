defmodule PhonixWeb.CurrentUser do
  use PhonixWeb, :live_view
  alias Phonix.Accounts

  @impl true
  def on_mount(:default, _params, session, socket) do
    current_scope =
      case session["user_token"] do
        nil -> nil

        token ->
          case Accounts.get_user_by_session_token(token) do
            {user, _auth_time} -> %{user: user}
            _ -> nil
          end
      end

    {:cont, socket |> assign(:current_scope, current_scope)}
  end
end
