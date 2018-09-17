defmodule Bricks.Socket.Tcp do
  alias Bricks.Socket
  alias Bricks.Error.{BadOwner, Closed, Posix}

  @behaviour Bricks.Socket

  @default_recv_timeout 5000
  @spec new(port(), map()) :: {:ok, Socket.t()} | {:error, {atom() | [atom()], atom() | [atom()] }}
  def new(tcp_port, %{}=opts) do
    recv_timeout = Map.get(opts, :recv_timeout, @default_recv_timeout)
    {:ok, active: active} = :inet.getopts(tcp_port, [:active])
    Socket.new %{
      module:       __MODULE__,
      state:        tcp_port,
      active:       active,
      data_tag:     :tcp,
      error_tag:    :tcp_error,
      closed_tag:   :tcp_closed,
      passive_tag:  :tcp_passive,
      recv_timeout: recv_timeout,
    }
  end

  def fetch_active(%Socket{state: tcp}) do
    case :inet.getopts(tcp, [:active]) do
      {:ok, active: val} -> {:ok, val}
      {:error, code} -> {:error, Posix.new(code)}
    end
  end

  def set_active(%Socket{state: tcp}=socket, active) do
    case :inet.setopts(tcp, active: active) do
      :ok -> {:ok, %{ socket | active: active}}
      {:error, code} -> {:error, Posix.new(code)}
    end
  end

  def recv(%Socket{state: tcp, active: false}=socket, size, timeout) do
    case :gen_tcp.recv(tcp, size, timeout) do
      {:ok, data} -> {:ok, data, socket}
      {:error, :closed} -> {:error, Closed.new()}
      {:error, reason}  -> {:error, Posix.new(reason)}
    end
  end

  def send_data(%Socket{state: tcp}=socket, data) do
    case :gen_tcp.send(tcp, data) do
      :ok -> {:ok, socket}
      {:error, :closed} -> {:error, Closed.new()}
      {:error, reason}  -> {:error, Posix.new(reason)}
    end
  end

  def close(%Socket{state: tcp}) do
    :gen_tcp.close(tcp)
  end
  
  def handoff(%Socket{state: tcp}=socket, pid) do
    case :gen_tcp.controlling_process(tcp, pid) do
      :ok -> {:ok, socket}
      {:error, :closed} -> {:error, Closed.new()}
      {:error, :badarg} -> {:error, BadOwner.new(pid)}
      {:error, posix}   -> {:error, Posix.new(posix)}
    end
  end

end
