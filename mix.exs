defmodule DistributedAttributeServer.Mixfile do
  use Mix.Project

  def project do
    [app: :distributed_attribute_server_application,
     version: "0.1.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: "(BETA) Distributed shared dictionary using master/slave replication and slave to master failover",
     package: package,
     name: "Distributed Attribute Server",
     docs: [source_url: "https://github.com/MishaConway/elixir-distributed-attribute-server"]]
  end

  defp package do
    [contributors: ["Misha Conway"],
    licenses: ["MIT"],
    links: %{github: "https://github.com/MishaConway/elixir-distributed-attribute-server"},
    maintainers: ["Misha Conway"],
    files: ~w(mix.exs README.md CHANGELOG.md lib)]
  end

  defp elixirc_paths(:test), do: ["lib", "test/lib", "test/mix"]
  defp elixirc_paths(_),     do: ["lib"]

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [ {:stringify, "~> 0.1.0"},
      {:attribute_server, "~> 0.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}]
  end
end
