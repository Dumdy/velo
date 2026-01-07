defmodule Velo.Provider do
  @moduledoc """
  Behaviour all providers must implement.
  """

  alias Velo.{Charge, Event, Error}

  @callback charge(map(), keyword()) ::
              {:ok, Charge.t()} | {:error, Error.t()}

  @callback verify(String.t(), keyword()) ::
              {:ok, Charge.t()} | {:error, Error.t()}

  @callback verify_webhook(Plug.Conn.t(), keyword()) ::
              {:ok, Event.t()} | {:error, :invalid_signature}
end
