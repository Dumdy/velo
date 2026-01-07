defmodule VeloTest do
  use ExUnit.Case
  alias Velo.Charge

  test "reference generator creates unique strings" do
    ref1 = Velo.reference()
    ref2 = Velo.reference()

    assert is_binary(ref1)
    assert is_binary(ref2)
    assert ref1 != ref2
    assert String.starts_with?(ref1, "VLO-")
  end
end
