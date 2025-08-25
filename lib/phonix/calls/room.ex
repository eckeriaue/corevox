defmodule Phonix.Calls.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :password_hash, :string
    field :user_id, :id
    belongs_to :owner, Phonix.Accounts.User
    has_many :room_members, Phonix.Calls.RoomMember
    many_to_many :members, Phonix.Accounts.User, join_through: Phonix.Calls.RoomMember

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs, user_scope) do
    room
    |> cast(attrs, [:name, :password_hash])
    |> validate_required([:name, :password_hash])
    |> put_change(:user_id, user_scope.user.id)
  end
end
