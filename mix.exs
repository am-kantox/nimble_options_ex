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
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      xref: [exclude: []],
      docs: docs(),
      dialyzer: [
        plt_file: {:no_warn, ".dialyzer/dialyzer.plt"},
        plt_add_deps: :app_tree,
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
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false}
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

  defp description do
    """
    Pack of custom functions to enhance the UX with `NimbleOptions`.
    """
  end

  defp package do
    [
      name: @app,
      files: ~w|lib mix.exs README.md LICENSE|,
      maintainers: ["Aleksei Matiushkin"],
      licenses: ["Kantox LTD"],
      links: %{
        "GitHub" => "https://github.com/am-kantox/#{@app}",
        "Docs" => "https://hexdocs.pm/#{@app}"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/#{@app}",
      source_url: "https://github.com/am-kantox/#{@app}",
      extras: ~w[README.md],
      groups_for_modules: []
    ]
  end
end
