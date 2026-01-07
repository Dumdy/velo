defmodule Velo.Providers.PaystackTest do
  use ExUnit.Case
  alias Velo.Providers.Paystack
  alias Velo.Charge

  # Mock HttpClient responses
  defmodule MockHttpClient do
    def post(_url, _payload, _secret) do
      {:ok,
       %{
         "data" => %{
           "id" => 123,
           "reference" => "test_ref",
           "amount" => 5000,
           "currency" => "NGN"
         }
       }}
    end

    def get(_url, _secret) do
      {:ok,
       %{
         "data" => %{
           "id" => 123,
           "reference" => "test_ref",
           "amount" => 5000,
           "currency" => "NGN",
           "status" => "success"
         }
       }}
    end
  end

  test "charge returns a normalized Charge struct" do
    # Override HttpClient in Paystack module for test
    Application.put_env(:velo, :http_client, MockHttpClient)

    {:ok, charge} = Paystack.charge(%{amount: 5000, email: "a@b.com"}, secret_key: "test")
    assert %Charge{} = charge
    assert charge.status == :pending
    assert charge.provider == :paystack
    assert charge.amount == 5000
  end

  test "verify returns succeeded charge" do
    Application.put_env(:velo, :http_client, MockHttpClient)

    {:ok, charge} = Paystack.verify("test_ref", secret_key: "test")
    assert charge.status == :succeeded
  end
end
