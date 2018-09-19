# Copyright (c) 2018 James Laver
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    :ok = Socket.send_data(sock, "hello world\n")
    {:ok, "hello world\n", %Socket{}} = Socket.recv(sock, 0, 1000)
  end
end
