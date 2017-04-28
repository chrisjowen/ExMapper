defmodule Exmapper.Mixfile do
  use Mix.Project

  def project do
    [app: :exmapper,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: [espec: :test],
     deps: deps() ++ test_deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "spec/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp test_deps do
    [
      {:espec, "~> 1.3.4", only: :test},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false}
    ]
  end

  defp deps do
    [
      { :uuid, "~> 1.1" }
    ]
  end
end
