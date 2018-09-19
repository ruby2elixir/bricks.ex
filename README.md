# bricks

A uniform low-level API over unix domain sockets, tcp and tcp/tls connections

## Status: Beta

Release checklist:
- Finish docstrings and moduledocs
- Untuple send_data

Missing:
- Tls connector and socket (pending tidy of old code)

<!-- Strange bugs: -->
<!-- - Tests fail when I uncap the size of Gen.header_map. It's like -->
<!--   they're not receiving all the data before the socket is closed, odd. -->

## Usage

```elixir

alias Bricks.Connector.Unix
alias Bricks.{Connector, Socket}

# Here we will connect to a unix socket for a fictional echo service
# and verify it echoes correctly
def main() do
  unix = Unix.new("/var/run/echo.sock")
  {:ok, socket} = Connector.connect(unix)
  
  # Let's start with passive mode, where we have to request new data
  {:ok,"", socket} = Socket.passify(h) # if the server sent more in the meantime, won't be ""
  :ok = Socket.send_data(socket, "hello world\n")
  {:ok, "hello world\n", socket} = Socket.recv(socket, 0)

  # Here's how you use active mode
  {:ok, socket} = Socket.set_active(socket, true)
  :ok = Socket.send_data(socket, "hello world\n")
  %Socket{state: state, data_tag: data}=socket
  receive do
    {^data, ^state, "hello world\n"} -> Socket.close(socket)
  after 1000 -> throw :timeout
  end

end
```

## Overview

### Sockets

A Socket represents a connected socket and provides a unified
interface for interacting with it. Presently there is only one socket,
`Bricks.Socket.Tcp` which wraps a gen_tcp port, but there are plans
for a TLS socket as well.

A socket may be in either 'passive' or 'active' mode, in the standard erlang
gen_tcp sense. When passive, you must call `Socket.recv/2` or `Socket.recv/3`
to receive additional data. When active, the data will be sent to you as messages,
along with messages to indicate an error, the socket being closed or the socket
being made passive (when `Socket.set_active/2` is provided an integer).

The `Socket` structure wraps a few fields:
```
:module       - callback module
:port         - the underlying port or data structure or pid or whatever
:active       - the current activity status of the socket
:recv_timeout - the timeout (in milliseconds or :infinity) for recv operations
```
There are also some tag fields which are used when you want to pattern match
in a receive (only when the socket is in active mode):

```
:data_tag    - When data is received
:error_tag   - When an error occurs
:closed_tag  - When the socket is closed
:passive_tag - When the socket is turned passive
```

Example usage:

```elixir
def collect(socket) do
  Socket.set_active(socket, true)
end

defp collect_output(
  %Socket{
    data_tag: data,
    error_tag: error,
    closed_tag: closed,
    passive_tag: passive,
    port: port,
    recv_timeout: timeout,
  }, acc \\ "") do
  receive do
    {^data,    ^port, data}   -> collect_output(socket, acc <> data)
    {^error,   ^port, reason} -> {:error, reason}
    {^closed,  ^port} -> {:ok, acc}
    {^passive, ^port} -> {:error, :went_passive} # demonstration purposes only
  after timeout -> {:ok, acc}
  end
end
```

### Connectors

The easiest way to get a socket is to use a connector

Connectors are responsible for establishing a connection

#### Unix Connector

```elixir
Bricks.Connector.Unix.new("/var/run/example.sock")
Bricks.Connector.Unix.new("/var/run/example.sock", [:binary]) # custom gen_tcp opts
```

The unix connector uses `gen_tcp` to establish a connection. It therefore returns a `Tcp` socket.

#### TCP Connector

```elixir
Bricks.Connector.Tcp.new("example.org", 80)
Bricks.Connector.Tcp.new("example.org", 80, [:binary]) # custom gen_tcp opts
```

<!-- #### TLS Connector -->

<!-- ```elixir -->
<!-- ``` -->

## Notes on erlang brokenness

- gen_tcp sockets start active for tcp and passive for unix. Possibly
  this is version dependent (yay!).
  Workaround: `Socket.set_active/2` or `Socket.passify/1`
- Going passive necessitates clearing the mailbox of existing messages
  Workaround: `Socket.passify/1`.
- Integer activities

## Copyright and License

Copyright (c) 2018 James Laver

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

