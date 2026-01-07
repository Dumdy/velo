defmodule Velo.WebhookTest do
  use ExUnit.Case
  use Plug.Test

  alias Velo.Webhook

  @secret "supersecret"
  @payload Jason.encode!(%{
             "id" => "evt_123",
             "event" => "charge.success",
             "data" => %{"amount" => 5000}
           })

  # Compute Paystack-like signature
  @signature :crypto.mac(:hmac, :sha256, @secret, @payload)
             |> Base.encode16(case: :lower)

  test "valid webhook calls on_event" do
    called = Agent.start_link(fn -> false end, name: :webhook_called)

    on_event = fn event ->
      Agent.update(:webhook_called, fn _ -> true end)
      assert event.id == "evt_123"
      assert event.type == "charge.success"
      assert event.data["amount"] == 5000
    end

    conn =
      conn(:post, "/webhooks/paystack", @payload)
      |> put_req_header("x-paystack-signature", @signature)
      |> assign(:thousand_island_raw_body, @payload)

    conn = Webhook.call(conn, provider: :paystack, on_event: on_event)
    assert conn.status == 200

    assert Agent.get(:webhook_called, & &1)
  end

  test "invalid signature returns 400" do
    conn =
      conn(:post, "/webhooks/paystack", @payload)
      |> put_req_header("x-paystack-signature", "wrong")
      |> assign(:thousand_island_raw_body, @payload)

    conn = Webhook.call(conn, provider: :paystack, on_event: fn _ -> :ok end)
    assert conn.status == 400
  end
end
