defmodule Corevox.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias Corevox.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rooms" do
    field :name, :string
    field :description, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :is_private, :boolean, default: false
    field :max_users, :integer

    belongs_to :owner, User, type: :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :password, :is_private, :max_users, :status, :owner_id])
    |> validate_required([:name, :owner_id])
    |> hash_password()
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end

end
