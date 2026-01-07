defmodule Velo.Error do
  @moduledoc """
  Standardized error struct for Velo operations.
  """

  defstruct [:code, :message, :provider]
end
