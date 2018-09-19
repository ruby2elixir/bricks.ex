# Copyright (c) 2018 James Laver
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
