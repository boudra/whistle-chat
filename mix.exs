defmodule WhistleChat.MixProject do
  use Mix.Project

  def project do
    [
      app: :whistle_chat,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {WhistleChat.Application, []},
      extra_applications: [:logger],
      applications: [:whistle, :plug, :plug_cowboy, :jason]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:whistle, git: "https://github.com/boudra/whistle.git", tag: "master"},

      {:plug, "~> 1.7"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
