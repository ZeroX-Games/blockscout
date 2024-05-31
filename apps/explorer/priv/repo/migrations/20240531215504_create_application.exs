defmodule Explorer.Repo.Migrations.CreateApplication do
  use Ecto.Migration

  def change do
    create table(:applications, primary_key: false) do
      add(:hash, :bytea, null: false, primary_key: true)
      add(:name, :string, null: true)
      add(:description, :string, null: true)
      timestamps()
    end
  end
end
