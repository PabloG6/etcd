defmodule EtcdTest do
  use ExUnit.Case
  doctest Etcd


  test "connects to client" do
    assert {:ok, pid} = Etcd.connect()
  end


  alias Etcd.Client
  test "writes a value in the etcd storage v3" do
    assert {ok, pid} = Etcd.connect()
    {:ok, response} = Etcd.Client.V3.put(pid, {"strong", "man"})
    IO.inspect response
  end


  test "gets a value in the etcd storage v3" do
    assert {ok, pid} = Etcd.connect()
    {:ok, response} = Etcd.Client.V3.put(pid, {"strong", "man"})
    IO.inspect response
  end
end
