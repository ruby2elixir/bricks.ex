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

defmodule Bricks.Tls do
  def read_pem_cert(path) do
    case File.read(path) do
      {:ok, data} ->
	case :public_key.pem_decode(data) do
	  [{:Certificate, der, :not_encrypted}] -> {:ok, der}
	  _ -> {:error, {:not_cert, path}}
	end
      _ -> {:error, {:cert_not_found, path}}
    end
  end

  def read_pem_rsa_key(path) do
    case File.read(path) do
      {:ok, data} ->
	case :public_key.pem_decode(data) do
	  [{:RSAPrivateKey, der, :not_encrypted}] -> {:ok, {:RSAPrivateKey, der}}
	  _ -> {:error, :not_rsa_key}
	end
      _ -> {:error, {:key_not_found, path}}
    end
  end

end
