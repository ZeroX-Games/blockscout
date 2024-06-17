defmodule EthereumJSONRPC.TransactionApplication do
  import EthereumJSONRPC, only: [json_rpc: 2, request: 1]
  require Logger

  def fetch(transactions_params, json_rpc_named_arguments) when is_list(transactions_params) do
    Logger.info(fn -> ["Fetching done txs: ", inspect(transactions_params)] end, step: :import)

    {requests, id_to_transaction_params} =
      transactions_params
      # filter transactions_params with zxTxType == 0x01
      |> Enum.filter(fn transaction_param -> transaction_param.zxTxType == 1 end)
      |> Stream.with_index()
      |> Enum.reduce({[], %{}}, fn {%{created_contract_address_hash: contract_hash} = transaction_params, id},
                                   {acc_requests, acc_id_to_transaction_params} ->
        requests = [request(id, contract_hash) | acc_requests]
        id_to_transaction_params = Map.put(acc_id_to_transaction_params, id, transaction_params)
        {requests, id_to_transaction_params}
      end)

    Logger.info("Fetching application creation transactions", count: Enum.count(requests))
  end

  defp request(id, contract_hash) when is_integer(id) and is_binary(contract_hash) do
    Logger.info("Testing fetching block & application creation transaction", id: id, contract_hash: contract_hash)

    request(%{
      id: id,
      method: "eth_getApplicationDetails",
      params: [contract_hash]
    })
  end
end
