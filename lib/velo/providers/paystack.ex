defmodule Velo.Providers.Paystack do
  alias Velo.Event



  
  def verify_webhook(conn) do
    secret = Application.fetch_env!(:velo, [:providers, :paystack, :webhook_secret])
    signature = Plug.Conn.get_req_header(conn, "x-paystack-signature") |> List.first()

    raw_body = conn.assigns[:raw_body]

    computed_signature =
      :crypto.mac(:hmac, :sha256, secret, raw_body)
      |> Base.encode16(case: :lower)

    if signature == computed_signature do
      body = Jason.decode!(raw_body)

      {:ok,
       %Event{
         id: body["id"],
         type: body["event"],
         provider: :paystack,
         data: body["data"],
         raw: body
       }}
    else
      {:error, :invalid_signature}
    end
  end
end
