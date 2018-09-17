defmodule Bricks.Socket do
  @enforce_keys [:module, :state, :active, :data_tag, :error_tag, :closed_tag, :passive_tag, :recv_timeout]
  defstruct @enforce_keys

  alias Bricks.Socket
  alias Bricks.Error.{BadOwner, Closed, Inactive, Posix}

  @type active :: boolean() | :once | -32768..32767
  @type data :: binary() | charlist()
  @type t :: %Socket{
    module:       atom(),
    state:        term(),
    active:       active(),
    data_tag:     atom(),
    error_tag:    atom(),
    closed_tag:   atom(),
    passive_tag:  atom(),
    recv_timeout: timeout(),
  }

  @spec new(map()) :: {:ok, t()} | {:error, {atom() | [atom()], atom() | [atom()] }}
  def new(%{module: m, state: s, active: a, data_tag: d, error_tag: e, closed_tag: c, passive_tag: p}=opts) do
    t = Map.get(opts, :recv_timeout, 5000)
    extra = Map.keys(Map.drop(opts, [:module, :state, :active, :data_tag, :error_tag, :closed_tag, :passive_tag, :recv_timeout]))
    cond do
      not is_atom(m) -> {:error, {:module, :atom}}
      not is_atom(d) -> {:error, {:data_tag, :atom}}
      not is_atom(e) -> {:error, {:error_tag, :atom}}
      not is_atom(c) -> {:error, {:closed_tag, :atom}}
      not is_atom(p) -> {:error, {:passive_tag, :atom}}
      not (is_boolean(a) or (a == :once) or (is_integer(a) and (a >= -32767) and (a <= 32767))) ->
        {:error, {:active, [:bool, :non_neg_int, :once]}}
      not ((t == :infinity) or (is_integer(t) and (t > 0))) ->
        {:error, {[:recv_timeout, :timeout], [:infinity, :non_neg_int]}}
      [] != extra ->
        {:error, {:invalid_keys, extra}}
      true ->
        {:ok, %Socket{
            module:       m,
            state:        s,
            active:       a,
            data_tag:     d,
            error_tag:    e,
            closed_tag:   c,
            passive_tag:  p,
            recv_timeout: t,
         }}
    end
  end

  # Receiving data

  @typedoc false
  @type recv_error :: Closed.t() | Posix.t()
  @typedoc false
  @type recv_result :: {:ok, data(), t()} | {:error, recv_error()}

  @spec     recv(t(), non_neg_integer()) :: recv_result()
  def recv(%Socket{recv_timeout: t}=socket, size) do
    recv(socket, size, t)
  end

  @callback recv(t(), non_neg_integer(), timeout()) :: recv_result()
  @spec     recv(t(), non_neg_integer(), timeout()) :: recv_result()
  def recv(%Socket{module: module, active: false}=socket, size, timeout) do
    apply(module, :recv, [socket, size, timeout])
  end

  # Sending data

  @typedoc false
  @type send_error :: Closed.t() | Posix.t()
  @typedoc false
  @type send_result :: {:ok, t()} | {:error, send_error()}

  @callback send_data(t(), data()) :: send_result()
  @spec     send_data(t(), data()) :: send_result()
  def send_data(%Socket{module: module}=socket, data) do
    apply(module, :send_data, [socket, data])
  end
  
  # Setting the socket activity

  @typedoc false
  @type set_active_error :: Posix.t()
  @typedoc false
  @type set_active_return :: {:ok, t()} | {:error, set_active_error()}

  @callback set_active(t(), active()) :: set_active_return()
  @spec     set_active(t(), active()) :: set_active_return()
  def set_active(%Socket{module: module}=socket, active) do
    apply(module, :set_active, [socket, active])
  end

  # Fetching the socket activity

  @typedoc false
  @type fetch_active_error  :: Posix.t()
  @typedoc false
  @type fetch_active_return :: {:ok, active()} | {:error, fetch_active_error()}

  @callback fetch_active(t()) :: fetch_active_return()
  @spec     fetch_active(t()) :: fetch_active_return()
  def fetch_active(%Socket{module: module}=socket) do
    apply(module, :fetch_active, [socket])
  end

  # Closing the socket
  
  @callback close(t()) :: :ok
  @spec     close(t()) :: :ok
  def close(%Socket{module: module}=socket) do
    apply(module, :close, [socket])
  end

  # Handing off the socket to another process

  @typedoc false
  @type handoff_error :: Closed.t() | BadOwner.t() | Posix.t()
  @typedoc false
  @type handoff_return :: {:ok, t()} | {:error, handoff_error()}

  @callback handoff(t(), pid()) :: handoff_return()
  @spec     handoff(t(), pid()) :: handoff_return()
  def handoff(%Socket{module: module}=socket, pid) when is_pid(pid) do
    apply(module, :handoff, [socket, pid])
  end

  @doc """
  Turns the socket passive, clearing any active data out of the mailbox
  Success: {:ok, leftover} when is_binary(leftover)
  Error: {:error, reason}
  """
  def passify(%Socket{}=socket) do
    with {:ok, socket} <- set_active(socket, false),
      do: passify_h(socket, "")
  end
  defp passify_h(%Socket{state: state, data_tag: d, error_tag: e, closed_tag: c, passive_tag: p}=socket, acc) do
    if active?(socket) do
      receive do
	{^p, ^state} -> {:ok, acc, %{socket | active: false}}
	{^e, ^state, reason} -> {:error, reason}
	{^c, ^state} -> {:closed, acc}
	{^d, ^state, msg} ->
	  case msg do
	    {:data, data} -> passify_h(socket, acc <> data)
	    :closed -> {:closed, acc}
	    {:error, reason} -> {:error, reason}
	  end
      after 0 -> {:ok, acc, %{socket | active: false}}
      end
    else
      {:ok, acc,  %{socket | active: false}}
    end
  end

  def active?(%Socket{active: active}), do: active != false
  def passive?(%Socket{active: active}), do: active == false

  def valid_active?(:once), do: true
  def valid_active?(a) when is_boolean(a), do: true
  def valid_active?(n) when is_integer(n) and n >= -32767 and n <= 32767, do: true

end
