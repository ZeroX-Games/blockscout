defmodule Explorer.Chain.Import.Runner.Applications do
  @moduledoc """
  Bulk imports `t:Explorer.Chain.Application.t/0`.
  """

  require Ecto.Query

  import Ecto.Query, only: [from: 2]

  alias Ecto.{Multi}
  alias Explorer.Chain.{Import, Application}
  alias Explorer.Prometheus.Instrumenter

  @behaviour Import.Runner

  # milliseconds
  @timeout 60_000

  @type imported :: [Application.t()]

  @impl Import.Runner
  def ecto_schema_module, do: Application

  @impl Import.Runner
  def option_key, do: :applications

  @impl Import.Runner
  def imported_table_row do
    %{
      value_type: "[#{ecto_schema_module()}.t()]",
      value_description: "List of `t:#{ecto_schema_module()}.t/0`s"
    }
  end

  @impl Import.Runner
  def run(multi, changes_list, %{timestamps: timestamps} = options) do
    insert_options =
      options
      |> Map.get(option_key(), %{})
      |> Map.take(~w(on_conflict timeout)a)
      |> Map.put_new(:timeout, @timeout)
      |> Map.put(:timestamps, timestamps)

    Multi.run(multi, :applications, fn repo, _ ->
      Instrumenter.block_import_stage_runner(
        fn -> insert(repo, changes_list, insert_options) end,
        :block_referencing,
        :applications,
        :applications
      )
    end)
  end

  @impl Import.Runner
  def timeout, do: @timeout

  defp insert(
         repo,
         changes_list,
         %{
           timeout: timeout,
           timestamps: timestamps
         } = options
       )
       when is_list(changes_list) do
    on_conflict = Map.get_lazy(options, :on_conflict, &default_on_conflict/0)
    ordered_changes_list = Enum.sort_by(changes_list, & &1.txHash)

    Import.insert_changes_list(
      repo,
      ordered_changes_list,
      conflict_target: :txHash,
      on_conflict: on_conflict,
      for: Application,
      returning: true,
      timeout: timeout,
      timestamps: timestamps
    )
  end

  def default_on_conflict do
    from(
      application in Application,
      update: [
        set: [
          txHash: fragment("COALESCE(EXCLUDED.txHash, ?)", application.name),
          contract_address_hash: fragment("COALESCE(EXCLUDED.contract_address_hash, ?)", application.symbol),
          inserted_at: fragment("LEAST(?, EXCLUDED.inserted_at)", application.inserted_at),
          updated_at: fragment("GREATEST(?, EXCLUDED.updated_at)", application.updated_at)
        ]
      ],
      where:
        fragment(
          "(EXCLUDED.txHash, EXCLUDED.contract_address_hash) IS DISTINCT FROM (?, ?)",
          application.txHash,
          application.contract_address_hash
        )
    )
  end
end
