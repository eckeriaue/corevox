defmodule Phonix.Calls.RoomMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "room_members" do
    field :role, :string
    field :room_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room_member, attrs, user_scope) do
    room_member
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> put_change(:user_id, user_scope.user.id)
  end
end
