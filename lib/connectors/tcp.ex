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

defmodule Bricks.Connector.Tcp do
  @enforce_keys [:host, :port, :tcp_opts, :recv_timeout, :connect_timeout]
  defstruct @enforce_keys
  alias Bricks.Connector
  alias Bricks.Connector.Tcp
 
  @default_connect_timeout 5000
  @default_recv_timeout 5000
  @default_tcp_opts [:binary]

  def new(%{host: host, port: port}=opts) do
    conn_timeout = Map.get(opts, :connect_timeout, @default_connect_timeout)
    recv_timeout = Map.get(opts, :recv_timeout, @default_recv_timeout)
    tcp_opts = Map.get(opts, :tcp_opts, @default_tcp_opts)
    %Tcp{
      host:            host,
      port:            port,
      tcp_opts:        tcp_opts,
      recv_timeout:    recv_timeout,
      connect_timeout: conn_timeout,
    }
  end
  
  defimpl Connector, for: Tcp do
    alias Bricks.Socket.Tcp
    def connect(tcp) do
      case :gen_tcp.connect(tcp.host, tcp.port, tcp.tcp_opts, tcp.connect_timeout) do
	{:ok, socket} -> Tcp.new(socket, %{recv_timeout: tcp.recv_timeout})
	{:error, reason} -> {:error, {:tcp_connect, reason}}
      end
    end
  end
end
