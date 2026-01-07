defmodule Velo.Webhook do
  @moduledoc """
  Handles provider webhooks for Velo.

  Works with Plug + Thousand Island to access raw request bodies.
  Normalizes events to `Velo.Event` structs.

  Example usage in your router:

      post "/webhooks/paystack" do
        opts = [
          provider: :paystack,
          on_event: &MyApp.Payments.handle_event/1
        ]

        Velo.Webhook.call(conn, opts)
      end
  """

  import Plug.Conn
  alias Velo.Event
  alias Velo.Providers.Paystack

  @doc """
  Processes a webhook request.

  Expects options:
    - `:provider` (atom) – :paystack, :flutterwave, etc.
    - `:on_event` (function) – callback to handle normalized events.
  """
  def call(conn, opts) do
    provider = Keyword.fetch!(opts, :provider)
    on_event = Keyword.fetch!(opts, :on_event)

    # Get raw body from Thousand Island
    raw_body = conn.assigns[:thousand_island_raw_body]

    # Assign raw body for downstream use
    conn = assign(conn, :raw_body, raw_body)

    case verify_provider(provider, conn) do
      {:ok, event} ->
        # Call the user-provided event handler
        on_event.(event)
        send_resp(conn, 200, "OK")

      {:error, :invalid_signature} ->
        send_resp(conn, 400, "Invalid signature")

      {:error, reason} ->
        send_resp(conn, 500, "Webhook processing error: #{inspect(reason)}")
    end
  end

  # ================================
  # Provider-specific verification
  # ================================
  defp verify_provider(:paystack, conn) do
    Paystack.verify_webhook(conn)
  end

  defp verify_provider(:flutterwave, conn) do
    # Placeholder for future Flutterwave integration
    {:error, :not_implemented}
  end
end

