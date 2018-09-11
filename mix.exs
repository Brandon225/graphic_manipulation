defmodule GraphicManipulations.MixProject do
  use Mix.Project

  def project do
    [
      app: :graphic_manipulations,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :hound, :httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mogrify, "~> 0.6.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:hound, "~> 1.0"},
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"}
    ]
  end
end
