Velo

Velo is a provider-agnostic payments library for Elixir, inspired by stripity_stripe. It allows developers to integrate multiple payment providers (like Paystack, Flutterwave, Stripe, etc.) with a unified API, including webhook handling, charge creation, and verification, without requiring Phoenix.

Velo is designed for plain Elixir applications, using Plug, Bandit, and Thousand Island for lightweight HTTP handling.

Features

Unified API for multiple payment providers

Normalized structs: Velo.Charge, Velo.Event, Velo.Error

Provider-agnostic: switch providers easily

Webhook support with signature verification

Works in plain Elixir, no Phoenix required

Easy to extend with new providers

Installation

Add Velo to your mix.exs dependencies:

defp deps do
  [
    {:velo, "~> 0.1.0"},
    {:plug, "~> 1.18"},
    {:bandit, "~> 1.10"},
    {:thousand_island, "~> 1.2"},
    {:jason, "~> 1.5"}
  ]
end


Fetch the dependencies:

mix deps.get

Configuration

Configure Velo in config/config.exs:

config :velo,
  default_provider: :paystack,
  providers: [
    paystack: [
      secret_key: System.get_env("PAYSTACK_SECRET_KEY"),
      webhook_secret: System.get_env("PAYSTACK_WEBHOOK_SECRET")
    ],
    flutterwave: [
      secret_key: System.get_env("FLUTTERWAVE_SECRET_KEY"),
      webhook_secret: System.get_env("FLUTTERWAVE_WEBHOOK_SECRET")
    ]
  ]


default_provider sets the provider used when none is specified.

providers contains credentials and secrets for each provider.

Usage
Generate a Reference
ref = Velo.reference()

Create a Charge
{:ok, charge} =
  Velo.charge(
    amount: 5000,
    currency: "NGN",
    email: "user@example.com",
    reference: ref
  )

IO.inspect(charge)


Returns a Velo.Charge struct:

%Velo.Charge{
  id: 123,
  reference: "VLO-AB12CD34",
  amount: 5000,
  currency: "NGN",
  status: :pending,
  provider: :paystack,
  raw: %{} # raw provider response
}

Verify a Charge
{:ok, verified_charge} = Velo.verify(charge.reference)
IO.inspect(verified_charge)


Returns a normalized Velo.Charge struct with updated status.

Handling Webhooks

Velo provides a Plug-based webhook handler compatible with Thousand Island:

Router Example
defmodule MyApp.Router do
  use Plug.Router
  alias Velo.Webhook

  plug ThousandIsland
  plug Plug.Parsers, parsers: [:json], pass: ["*/*"], json_decoder: Jason
  plug :match
  plug :dispatch

  post "/webhooks/paystack" do
    Webhook.call(conn,
      provider: :paystack,
      on_event: &MyApp.Payments.handle_event/1
    )
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end

Implement the Event Handler
defmodule MyApp.Payments do
  alias Velo.Event

  def handle_event(%Event{id: id, type: type, data: data}) do
    IO.inspect({id, type, data}, label: "Received Velo Event")

    case type do
      "charge.success" -> :ok
      "charge.failed" -> :ok
      _ -> :ok
    end
  end
end


Webhook events are normalized to Velo.Event, regardless of the provider.

Extending with New Providers

Create a module implementing Velo.Provider:

defmodule Velo.Providers.Stripe do
  @behaviour Velo.Provider

  # Implement `charge/2`, `verify/2`, `verify_webhook/2`
end


Add credentials in your config:

config :velo,
  providers: [
    stripe: [
      secret_key: System.get_env("STRIPE_SECRET_KEY"),
      webhook_secret: System.get_env("STRIPE_WEBHOOK_SECRET")
    ]
  ]


Use the provider by specifying it in Velo.charge/1 or Velo.verify/1:

Velo.charge(provider: :stripe, amount: 1000, email: "a@b.com")

Testing

Velo includes ExUnit tests for:

Reference generation

Paystack adapter (charge/1, verify/1)

Webhook signature verification

Run tests:

mix test

Non-Goals

Velo intentionally does not:

Manage wallets or balances

Replace provider dashboards

Handle UI or redirects

Include payment scheduling or subscriptions (yet)

This keeps Velo lightweight and focused.

Example Application

A minimal Velo-based app includes:

lib/my_app/router.ex → Plug router with webhooks

lib/my_app/payments.ex → Event handler

application.ex → Starts Bandit server

config/config.exs → Provider credentials

This allows developers to run a fully functional payment API without Phoenix.

License

MIT © [Your Name / Company]

