defmodule Explorer.Chain.Application do
  use Explorer.Schema

  alias Ecto.Changeset
  alias Explorer.Chain.{Hash}

  @type t :: %__MODULE__{
          name: String.t() | nil,
          description: String.t() | nil
        }

  @primary_key {:hash, Hash.Address, autogenerate: false}
  schema "applications" do
    field(:name, :string)
    field(:description, :string)
    timestamps()
  end

  def changeset(%__MODULE__{} = smart_contract, attrs) do
    smart_contract
    |> cast(attrs, [
      :name,
      :description
    ])
    |> validate_required([
      :hash
    ])
    |> unique_constraint(:hash)
  end
end
