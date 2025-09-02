defmodule Phonix.Calls.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :password, :string, virtual: true
    field :description, :string
    field :password_hash, :string
    belongs_to :owner, Phonix.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :password])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 100)
  end

  @doc false
  def changeset(room, attrs, user_scope) do
    room
    |> cast(attrs, [:name, :description, :password_hash])
    |> validate_required([:name])
    |> put_change(:owner_id, user_scope.user.id)
  end
end
