defmodule Bricks.Error.Timeout do
  @enforce_keys []
  defstruct @enforce_keys

  def new(), do: %__MODULE__{}
end
defmodule Bricks.Error.Posix do
  @enforce_keys [:code]
  defstruct @enforce_keys

  alias Bricks.Error.Timeout

  def new(:etimedout), do: Timeout.new()
  def new(code), do: %__MODULE__{code: code}

end
defmodule Bricks.Error.Closed do
  @enforce_keys []
  defstruct @enforce_keys

  def new(), do: %__MODULE__{}
end
