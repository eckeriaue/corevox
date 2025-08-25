defmodule Phonix.Calls.RoomMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "room_members" do
    belongs_to :room, Phonix.Calls.Room
    belongs_to :user, Phonix.Accounts.User
    field :role, :string

    timestamps(type: :utc_datetime)
  end


  @doc false
  def changeset(room_member, attrs) do
    room_member
    |> cast(attrs, [:room_id, :user_id, :role])
    |> validate_required([:room_id, :user_id])
    |> unique_constraint(:user_id, name: :room_members_room_id_user_id_index)
  end
end
