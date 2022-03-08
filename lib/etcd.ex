defmodule Etcd do
  @moduledoc """
  Documentation for `Etcd`.
  """
  alias Etcd.Client


  def connect() do
    Client.V3.connect([])
  end
end
