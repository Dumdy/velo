defmodule Velo.Event do
  @moduledoc """
  Normalized webhook event struct.
  """

  defstruct [
    :id,
    :type,
    :provider,
    :data,
    :raw
  ]
end
