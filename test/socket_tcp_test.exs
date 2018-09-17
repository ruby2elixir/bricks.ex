defmodule Bricks.Socket.TcpTest do
  use ExUnit.Case
  alias Bricks.{Connector, Socket}
  import BricksTest.EchoServices
  alias Bricks.Connector.{Tcp,Unix}

  test "tcp passive" do
    {:ok, port} = echo_tcp()
    tcp = Tcp.new(%{host: {127,0,0,1}, port: port})
    {:ok, sock} = Connector.connect(tcp)
    {:ok, "", sock} = Socket.passify(sock)
    {:ok, sock} = Socket.send_data(sock, "hello world\n")
    {:ok, "hello world\n", %Socket{}} = Socket.recv(sock, 0, 1000)
  end
  test "tcp active" do
    {:ok, port} = echo_tcp()
    tcp = Tcp.new(%{host: {127,0,0,1}, port: port})
    {:ok, sock} = Connector.connect(tcp)
    {:ok, sock} = Socket.set_active(sock, true)
    {:ok, sock} = Socket.send_data(sock, "hello world\n")
    %Socket{state: s}=sock
    assert_receive {:tcp, ^s, "hello world\n"}, 1000
  end

  test "unix passive" do
    {:ok, path} = echo_unix()
    unix = Unix.new(path)
    {:ok, sock} = Connector.connect(unix)
    {:ok, "", sock} = Socket.passify(sock)
    {:ok, sock} = Socket.send_data(sock, "hello world\n")
    {:ok, "hello world\n", %Socket{}} = Socket.recv(sock, 0, 1000)
  end
  test "unix active" do
    {:ok, path} = echo_unix()
    unix = Unix.new(path)
    {:ok, sock} = Connector.connect(unix)
    {:ok, sock} = Socket.set_active(sock, true)
    {:ok, sock} = Socket.send_data(sock, "hello world\n")
    %Socket{state: s}=sock
    assert_receive {:tcp, ^s, "hello world\n"}, 1000
  end

end
