defmodule Velo.MixProject do
  use Mix.Project

  def project do
    [
      app: :velo,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.19"},
      {:tesla, "~> 1.15"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.10"},
      {:thousand_island, "~> 1.4"}
    ]
  end
end
