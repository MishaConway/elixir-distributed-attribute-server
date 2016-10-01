defmodule DistributedAttributeServer.States.MasterState do
  use DistributedAttributeServer.States.State

  def append_slave(component, slave) do
    IO.puts "appending slave"
    :global.set_lock {"master_state", self}, [Node.self]
    comp = get component
    comp = Map.put comp, :slaves, Map.merge(comp[:slaves] || %{}, slave)
    IO.puts "after merging slave comp is"
    IO.inspect comp
    set component, comp
    :global.del_lock {"master_state", self}, [Node.self]
    IO.puts "after appending slaves, it is now #{:i.i all}"
  end
end
