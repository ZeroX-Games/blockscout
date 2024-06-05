defmodule Explorer.Repo.Migrations.CreateApplication do
  use Ecto.Migration

  def change do
    create table(:applications, primary_key: false) do
      add(:txHash, :bytea, null: false, primary_key: true)
      add(:contract_address_hash, references(:addresses, column: :hash, on_delete: :delete_all, type: :bytea), null: true)
      add(:name, :string, null: true)
      add(:description, :string, null: true)
      timestamps()
    end
  end
end
