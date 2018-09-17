defmodule Bricks.Error.Timeout do
  @enforce_keys []
  defstruct @enforce_keys

  @type t :: %__MODULE__{}
  def new(), do: %__MODULE__{}
end
