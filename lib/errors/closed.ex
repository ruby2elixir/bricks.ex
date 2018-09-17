defmodule Bricks.Error.Closed do
  @enforce_keys []
  defstruct @enforce_keys

  alias Bricks.Error.Closed

  @type t :: %Closed{}
  def new(), do: %Closed{}
end
