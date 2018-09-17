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
