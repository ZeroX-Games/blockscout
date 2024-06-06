defmodule Indexer.Transform.Applications do
  require ExRLP
  require ExKeccak
  require Logger
  import Bitwise

  def transform_application(transaction) do
    # Calculate the contract address
    contract_address_hash = calculate_contract_address(transaction.from_address_hash, transaction.nonce)

    # Transform the transaction
    transaction
    |> Map.put(:contract_address_hash, contract_address_hash)
  end

  # Calculate the contract address
  defp calculate_contract_address(from_address_hash, nonce) do
    from_address_bin = decode_hex(from_address_hash)
    encoded = ExRLP.encode([from_address_bin, nonce])
    Logger.info("encoded: #{inspect(encoded)}")
    hashed = ExKeccak.hash_256(encoded)
    contract_address = :binary.part(hashed, byte_size(hashed) - 20, 20)
    "0x" <> Base.encode16(contract_address)
  end

  # Helper function to decode an Ethereum address from hex (without '0x') to binary
  defp decode_hex(hex) do
    hex
    |> String.replace_prefix("0x", "")
    |> Base.decode16!(case: :mixed)
  end
end
