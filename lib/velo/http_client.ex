defmodule Velo.HttpClient do
  @moduledoc """
  Simple HTTP client wrapper for Velo providers.
  """

  def post(url, payload, secret) do
    headers = [{"Authorization", "Bearer #{secret}"}, {"Content-Type", "application/json"}]

    case Tesla.post(url, Jason.encode!(payload), headers: headers) do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, Jason.decode!(body)}
      {:ok, %Tesla.Env{status: status}} -> {:error, status}
      {:error, reason} -> {:error, reason}
    end
  end

  def get(url, secret) do
    headers = [{"Authorization", "Bearer #{secret}"}]

    case Tesla.get(url, headers: headers) do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, Jason.decode!(body)}
      {:ok, %Tesla.Env{status: status}} -> {:error, status}
      {:error, reason} -> {:error, reason}
    end
  end
end
