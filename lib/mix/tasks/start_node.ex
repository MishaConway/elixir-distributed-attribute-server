defmodule Mix.Tasks.StartNode do
  use Mix.Task

 @shortdoc "Starts a node"
 def run(_) do
   log "I am alive"

   wait_for_test_node 0

   SharedDict.set "cool", 123
   wait
 end

 def wait do
   wait
 end

 def wait_for_test_node 0 do
   wait_for_test_node Enum.count(Node.list)
 end

 def wait_for_test_node _num_connected_nodes do
   log "nodes is #{:i.i Node.list}"
 end

 def values :node1@localhost do
   [cool: 123, awesome: "nice", rad: 999]
 end

 def values :node2@localhost do
   [gnarly: "totally", dope: 7777, radical: 111]
 end

 def log str do
  IO.puts "`#{:i.i Node.self}`: #{:i.i str}"
 end
end
