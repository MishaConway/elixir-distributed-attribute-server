defmodule DistributedAttributeServerTest do
  use ExUnit.Case
#  import :meck
  doctest DistributedAttributeServer

#  setup do
#    new :net_kernel, [:unstick]
#    new Node
#    on_exit &unload/0
#    :ok
#  end

  test "it can set an attribute" do
    IO.puts "I am #{:i.i Node.self}"
    Node.connect :node1@localhost
    Node.connect :node2@localhost
    SharedDict.set :sweet, 456
  end

  test "it can get an attribute" do
    IO.puts "In test 2, Node.list is #{:i.i Node.list}"
    #Node.connect :node1@localhost
    #Node.connect :node2@localhost
    #:timer.sleep(5000)
    assert 123 == SharedDict.get("cool")
  end
end
