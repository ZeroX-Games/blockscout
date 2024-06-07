defmodule Explorer.Chain.Application do
  use Explorer.Schema

  alias Ecto.Changeset
  alias Explorer.Chain.{Hash}

  @type t :: %__MODULE__{
          txHash: Hash.t(),
          contract_address: %Ecto.Association.NotLoaded{} | Address.t() | nil,
          contract_address_hash: Hash.Address.t() | nil
        }

  # Defines how to encode the struct to JSON, only allowing the specified fields
  @derive {Poison.Encoder,
           only: [
             :txHash
           ]}
  @derive {Jason.Encoder,
           only: [
             :txHash
           ]}

  @primary_key {:txHash, Hash.Full, autogenerate: false}
  schema "applications" do
    belongs_to(
      :contract_address,
      Address,
      foreign_key: :contract_address_hash,
      references: :hash,
      type: Hash.Address
    )

    timestamps()
  end

  def changeset(%__MODULE__{} = smart_contract, attrs) do
    smart_contract
    |> cast(attrs, [
      :txHash,
      :contract_address_hash
    ])
    |> validate_required([
      :txHash
    ])
    |> unique_constraint(:txHash)
  end
end
