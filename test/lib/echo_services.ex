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

defmodule BricksTest.EchoServices do

  def echo_tcp() do
    {:ok, listen} = :gen_tcp.listen(0, [:binary])
    {:ok, port} = :inet.port(listen)
    spawn_link(fn -> echo(listen) end)
    {:ok, port}
  end

  @test_sock "/tmp/bricks-test.sock"
  def echo_unix() do
    case :file.delete(@test_sock) do # It's okay for it not to exist but nothing else
      :ok -> :ok
      {:error, :enoent} -> :ok
    end
    {:ok, listen} = :gen_tcp.listen(0, [:binary, {:ifaddr,{:local,@test_sock}}])
    spawn_link(fn -> echo(listen) end)
    {:ok, @test_sock}
  end

  # def echo_tls() do
  # end

  # This is horrible, but it somehow works
  def echo(listen) do
    {:ok, socket} = :gen_tcp.accept(listen, 1000)
    receive do
      {:tcp, ^socket, data} -> :gen_tcp.send(socket, data)
    after 1000 -> throw :error
    end
    :gen_tcp.close(socket)
  end

end
