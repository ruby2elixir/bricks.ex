defmodule Bricks.Util do

  alias Bricks.Socket
  
  @doc "Attempts to resolve a hostname"
  @spec resolve_host(binary() | charlist()) ::
    {:ok, binary(), atom(), [binary()]} | {:error, {:invalid_host, [any()], {any(),any()}}}

  def resolve_host(host) when is_binary(host) do
    resolve_host(String.to_charlist(host))
  end
  def resolve_host(host) when is_list(host) do
    case :inet_res.gethostbyname(host, :inet6) do
      {:ok, {:hostent, name, _aliases, addrtype, _length, ips}} ->
	{:ok, name, addrtype, ips}
      other -> {:error, {:invalid_host, host, other}}
    end
  end

  @spec active?(Socket.active()) :: boolean()
  def active?(a), do: a != false

  @spec passive?(Socket.active()) :: boolean()
  def passive?(a), do: a == false

end
