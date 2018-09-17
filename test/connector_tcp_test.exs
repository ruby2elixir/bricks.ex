defmodule Bricks.Connector.TcpTest do
  use ExUnit.Case
  alias Bricks.{Connector,Socket}
  import BricksTest.EchoServices
  alias Bricks.Connector.Tcp
  test "echo passive" do
    {:ok, port} = echo_tcp()
    tcp = Tcp.new(%{host: {127,0,0,1}, port: port})
    {:ok, sock} = Connector.connect(tcp)
    {:ok, "", sock} = Socket.passify(sock)
    Socket.send_data(sock, "hello world\n")
    {:ok, "hello world\n", _sock} = Socket.recv(sock, 0, 1000)
  end

  test "echo active" do
    {:ok, port} = echo_tcp()
    tcp = Tcp.new(%{host: {127,0,0,1}, port: port})
    {:ok, sock} = Connector.connect(tcp)
    {:ok, sock} = Socket.set_active(sock, true)
    Socket.send_data(sock, "hello world\n")
    %Socket{state: s}=sock
    assert_receive {:tcp, ^s, "hello world\n"}, 1000
  end

  test "recv passive" do
    {:ok, port} = echo_tcp()
    tcp = Tcp.new(%{host: {127,0,0,1}, port: port})
    {:ok, sock} = Connector.connect(tcp)
    {:ok, "", sock} = Socket.passify(sock)
    Socket.send_data(sock, "hello world\n")
    {:ok, "hello world\n", _sock} = Socket.recv(sock, 0, 1000)
    {:ok, port} = echo_tcp()
    tcp = Tcp.new(%{host: {127,0,0,1}, port: port})
    {:ok, sock} = Connector.connect(tcp)
    {:ok, "", sock} = Socket.passify(sock)
    Socket.send_data(sock, "hello world\n")
    {:ok, "hello world\n", _sock} = Socket.recv(sock, 0, 1000)
  end

end
