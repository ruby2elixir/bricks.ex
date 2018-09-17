defmodule Bricks.Error.Active do
  @enforce_keys []
  defstruct @enforce_keys

  alias Bricks.Error.Active

  @type t :: %Active{}
  def new(), do: %Active{}
end
