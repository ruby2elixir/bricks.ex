defmodule Bricks.Connector.Unix do
  @enforce_keys [:path, :tcp_opts, :connect_timeout, :recv_timeout]
  defstruct @enforce_keys
  alias Bricks.Connector
  alias Bricks.Connector.Unix

  @default_tcp_opts [:binary, {:active, false}]
  @default_connect_timeout 3000
  @default_recv_timeout 3000

  def new(path, opts \\ %{})
  def new(path, %{}=opts) do
    conn_timeout = Map.get(opts, :connect_timeout, @default_connect_timeout)
    recv_timeout = Map.get(opts, :recv_timeout, @default_recv_timeout)
    tcp_opts = Map.get(opts, :tcp_opts, @default_tcp_opts)
    %Unix{
      path:            path,
      tcp_opts:        tcp_opts,
      connect_timeout: conn_timeout,
      recv_timeout:    recv_timeout,
    }
  end

  defimpl Connector, for: Unix do
    alias Bricks.Socket.Tcp
    def connect(unix) do
      case :gen_tcp.connect({:local, unix.path}, 0, unix.tcp_opts, unix.connect_timeout) do
	{:ok, socket} -> Tcp.new(socket, %{recv_timeout: unix.recv_timeout})
	{:error, reason} -> {:error, {:unix_connect, reason}}
      end
    end
  end

end
