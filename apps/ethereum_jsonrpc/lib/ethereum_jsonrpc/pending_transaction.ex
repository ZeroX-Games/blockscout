defmodule EthereumJSONRPC.PendingTransaction do
  @moduledoc """
   Defines pending transactions fetching functions
  """
  require Logger
  import EthereumJSONRPC, only: [json_rpc: 2, request: 1]
  alias EthereumJSONRPC.{Transaction, Transactions}

  @doc """
  Geth-style fetching of pending transactions (from `txpool_content`)
  """
  @spec fetch_pending_transactions_geth(EthereumJSONRPC.json_rpc_named_arguments()) ::
          {:ok, [Transaction.params()]} | {:error, reason :: term}
  def fetch_pending_transactions_geth(json_rpc_named_arguments) do
    # Logger.debug(fn -> ["JSON RPC, Pending transactions: "] end)
    with {:ok, transaction_data} <-
           %{id: 1, method: "txpool_content", params: []} |> request() |> json_rpc(json_rpc_named_arguments),
         {:transaction_data_is_map, true} <- {:transaction_data_is_map, is_map(transaction_data)} do
          Logger.info(fn -> ["Geth RAW Pending Txs-->: ", inspect(transaction_data)] end, step: :import)
      transactions_params =
        transaction_data["pending"]
        |> Enum.flat_map(fn {_address, nonce_transactions_map} ->
          nonce_transactions_map
          |> Enum.map(fn {_nonce, transaction} ->
            transaction
          end)
        end)

        |> Transactions.to_elixir()
        # |> Enum.map(fn transaction ->
        #   Logger.info(fn -> ["Pending transaction params to satisfy xichen's cri: ", inspect(transaction)] end)
        #   transaction
        #   end)
        |> Transactions.elixir_to_params()

        |> Enum.map(fn params ->
          # txpool_content always returns transaction with 0x0000000000000000000000000000000000000000000000000000000000000000 value in block hash and index is null.
          # https://github.com/ethereum/go-ethereum/issues/19897
          %{params | block_hash: nil, index: nil}


        end)
        Logger.info(fn -> ["Geth pending txs-->: ", inspect(transactions_params)] end, step: :import)
      {:ok, transactions_params}
    else
      {:error, _} = error -> error
      {:transaction_data_is_map, false} -> {:ok, []}
    end
  end

  @doc """
  parity-style fetching of pending transactions (from `parity_pendingTransactions`)
  """
  @spec fetch_pending_transactions_parity(EthereumJSONRPC.json_rpc_named_arguments()) ::
          {:ok, [Transaction.params()]} | {:error, reason :: term}
  def fetch_pending_transactions_parity(json_rpc_named_arguments) do
    with {:ok, transactions} <-
           %{id: 1, method: "parity_pendingTransactions", params: []}
           |> request()
           |> json_rpc(json_rpc_named_arguments) do
      transactions_params =
        transactions
        |> Transactions.to_elixir()
        |> Transactions.elixir_to_params()

      {:ok, transactions_params}
    end
  end

  @spec fetch_pending_transactions_besu(EthereumJSONRPC.json_rpc_named_arguments()) ::
          {:ok, [Transaction.params()]} | {:error, reason :: term}
  def fetch_pending_transactions_besu(json_rpc_named_arguments) do
    with {:ok, transactions} <-
           %{id: 1, method: "txpool_besuTransactions", params: []}
           |> request()
           |> json_rpc(json_rpc_named_arguments) do
      transactions_params =
        transactions
        |> Transactions.to_elixir()
        |> Transactions.elixir_to_params()

      {:ok, transactions_params}
    end
  end
end
