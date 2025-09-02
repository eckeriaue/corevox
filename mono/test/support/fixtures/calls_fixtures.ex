defmodule orvox.CallsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `orvox.Calls` context.
  """

  @doc """
  Generate a room_live.
  """
  def room_live_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        password_hash: "some password_hash"
      })

    {:ok, room_live} = orvox.Calls.create_room_live(scope, attrs)
    room_live
  end
end
