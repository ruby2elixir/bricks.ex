defmodule Bricks.Connector.UnixTest do
  use ExUnit.Case
  alias Bricks.{Connector, Socket}
  import BricksTest.EchoServices
  alias Bricks.Connector.Unix

  test "echo" do
    {:ok, path} = echo_unix()
    unix = Unix.new(path)
    {:ok, sock} = Connector.connect(unix)
    {:ok, "", sock} = Socket.passify(sock)
    {:ok, sock} = Socket.send_data(sock, "hello world\n")
    {:ok, "hello world\n", %Socket{}} = Socket.recv(sock, 0, 1000)
  end
end
