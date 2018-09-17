defmodule Bricks do

  defprotocol Connector do
    def connect(self)
  end

end
