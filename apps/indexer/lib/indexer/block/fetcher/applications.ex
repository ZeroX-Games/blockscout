defmodule Indexer.Block.Fetcher.Applications do
  require Logger

  alias Indexer.Block

  def fetch(
        %Block.Fetcher{json_rpc_named_arguments: json_rpc_named_arguments} = state,
        transaction_params
      ) do
    Logger.debug("fetching transaction receipts", count: Enum.count(transaction_params))
    stream_opts = [max_concurrency: state.receipts_concurrency, timeout: :infinity]

    transaction_params
    |> Enum.chunk_every(state.receipts_batch_size)
    |> Task.async_stream(&EthereumJSONRPC.fetch_transaction_applications(&1, json_rpc_named_arguments), stream_opts)
    # print result of last step
    |> Enum.map(&IO.inspect/1)
  end
end
