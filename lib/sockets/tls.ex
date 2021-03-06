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

# defmodule Bricks.Socket.Tls do
#   @enforce_keys [:socket]
#   defstruct @enforce_keys
# end

# import ProtocolEx

# alias Bricks.{Done, FlowControl, Socket}

# TODO: https://github.com/OvermindDL1/protocol_ex/issues/11
# defimplEx SocketTls, %Bricks.Socket.Tls{}, for: Socket do
#   @priority -1

#   def socket({_,tls}), do: tls.socket

#   def send_data(self={_,tls}, data) do
#     with {:error, reason} <- :ssl.send(tls.socket, data) do
#       Done.errored(self)
#       {:error, {:tls_send, reason}}
#     end
#   end

#   def recv_active(self={_,tls}, size, timeout) do
#     with {:error, reason} <- :ssl.recv(tls.socket, size, timeout) do
#       Done.errored(self)
#       {:error, {:tls_recv_active, reason}}
#     end
#   end

#   def recv_passive(self={_,tls}, timeout) do
#     s = tls.socket
#     receive do
#       {:ssl, ^s, data} -> {:ok, data}
#       {:ssl_error, ^s, reason} -> {:error, {:tls_recv_passive, reason}}
#       {:ssl_closed, ^s} -> {:error, {:tls_recv_passive, :closed}}
#     after
#       timeout -> {:error, :timeout}
#     end
#   end

  # def getopts(tls, opts) when is_list(opts) do
  #   with {:error, reason} <- :ssl.getopts(tls.socket, opts),
  #     do: {:error, {:tls_getopts, reason}}
  # end
  # def setopts(tls, opts) when is_list(opts) do
  #   with {:error, reason} <- :ssl.setopts(tls.socket, opts),
  #     do: {:error, {:tls_setopts, reason}}
  # end

#   def transfer({_, tls}, pid) do
#     with {:error, reason} <- :ssl.controlling_process(tls.socket, pid),
#       do: {:error, {:tls_transfer, reason}}
#   end

# end
