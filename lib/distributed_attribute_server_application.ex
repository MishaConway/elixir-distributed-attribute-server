defmodule DistributedAttributeServerApplication do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(DistributedAttributeServer.MasterState, []),
      worker(DistributedAttributeServer.SlaveState, [])
    ]

    # When one process fails we restart all of them to ensure a valid state. Jobs are then
    # re-loaded from redis. Supervisor docs: http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    opts = [
      strategy: :one_for_all,
      name: DistributedAttributeServer.Supervisor,
      max_seconds: 15,
      max_restarts: 3
    ]
    Supervisor.start_link(children, opts)
  end
end
