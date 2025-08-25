defmodule Phonix.Calls.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :owner, Phonix.Accounts.User
    has_many :room_members, Phonix.Calls.RoomMember
    many_to_many :members, Phonix.Accounts.User, join_through: Phonix.Calls.RoomMember

    timestamps(type: :utc_datetime)
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :password])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 100)
  end

  @doc false
  def changeset(room, attrs, user_scope) do
    room
    |> cast(attrs, [:name, :password_hash])
    |> validate_required([:name])
    |> put_change(:owner_id, user_scope.user.id)
  end
end
