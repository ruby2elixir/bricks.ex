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
