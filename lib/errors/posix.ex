defmodule Bricks.Error.Posix do
  @enforce_keys [:code]
  defstruct @enforce_keys

  alias Bricks.Error.{Posix, Timeout}

  @type t :: %Posix{
    code: :inet.posix(),
  }
  
  @spec new(:inet.posix()) :: Timeout.t() | t()
  def new(:etimedout), do: Timeout.new()
  def new(code), do: %__MODULE__{code: code}

end
