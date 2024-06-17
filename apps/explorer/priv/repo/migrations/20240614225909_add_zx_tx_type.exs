defmodule Explorer.Repo.Migrations.AddZxTxType do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add(:zxTxType, :integer, null: true)
    end
  end
end
