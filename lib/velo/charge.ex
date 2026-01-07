defmodule Velo.Charge do
  @moduledoc """
  Normalized Charge struct used across all providers.
  """

  @type status :: :pending | :succeeded | :failed

  defstruct [
    :id,
    :reference,
    :amount,
    :currency,
    :status,
    :provider,
    :raw
  ]
end
