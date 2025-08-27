defmodule Phonix.RoomMembers do
  import Ecto.Query, warn: false
  alias Phonix.Repo
  alias Phonix.Calls.RoomMember

  def get_by_id!(id) do
    RoomMember |> Repo.get!(id)
  end
end
