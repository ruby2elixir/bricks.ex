defmodule Bricks.Error.BadOwner do
  @enforce_keys [:got]
  defstruct @enforce_keys

  alias Bricks.Error.BadOwner

  @type t :: %BadOwner{
    got: term(),
  }

  @spec new(term()) :: t()
  def new(got), do: %BadOwner{got: got}
end
