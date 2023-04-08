defmodule NimbleOptionsEx.MixProject do
  use Mix.Project

  @app :nimble_options_ex
  @version "0.1.0"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [
        plt_file: {:no_warn, ".dialyzer/dialyzer.plt"},
        plt_add_deps: :transitive,
        plt_add_apps: [:nimble_options],
        list_unused_filters: true,
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  def application, do: []

  defp deps do
    [
      {:nimble_options, "~> 1.0"},
      # dev / test / ci
      {:credo, "~> 1.0", only: [:dev, :ci], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :ci], runtime: false},
      {:ex_doc, "~> 0.11", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      quality: ["format", "credo --strict", "dialyzer --unmatched_returns"],
      "quality.ci": [
        "format --check-formatted",
        "credo --strict",
        "dialyzer"
      ]
    ]
  end
end
