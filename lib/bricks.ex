defmodule Bricks do
  import ProtocolEx

  # defprotocolEx Client do
  #   def connect(client)
  #   def done(client, socket)
  #   def error(client, socket)
  # end

  defprotocol Connector do
    def connect(self)
  end

end
