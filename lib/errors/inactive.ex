defmodule Bricks.Error.Inactive do
  @enforce_keys []
  defstruct @enforce_keys

  alias Bricks.Error.Inactive

  @type t :: %Inactive{}
  def new(), do: %Inactive{}
end
