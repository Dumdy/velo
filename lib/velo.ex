defmodule Velo do
  @moduledoc """
  Public API for Velo payments library.
  """

  alias Velo.Providers.{Paystack, Flutterwave}

  def charge(opts) do
    provider =
      Keyword.get(opts, :provider, Application.get_env(:velo, :default_provider, :paystack))

    module = provider_module(provider)
    module.charge(opts)
  end

  def verify(reference, opts \\ []) do
    provider =
      Keyword.get(opts, :provider, Application.get_env(:velo, :default_provider, :paystack))

    module = provider_module(provider)
    module.verify(reference, opts)
  end

  def reference do
  "VLO-" <> (:crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower))
end

  defp provider_module(:paystack), do: Paystack
  defp provider_module(:flutterwave), do: Flutterwave
end
