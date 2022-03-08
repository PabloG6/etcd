defmodule Etcd.Client.V3 do
  @moduledoc """
  generates genserver information for etcd client.
  """
  use GenServer
require Logger
  defstruct [:conn, :from, response: %{}]

  def connect(_opts) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    port = Application.fetch_env!(:etcd, :port)

    {:ok, conn} = Mint.HTTP.connect(:http, "127.0.0.1", port)
    {:ok, %__MODULE__{conn: conn}}
  end

  def put(pid, data) do
    GenServer.call(pid, {:put, data})
  end

  def delete(pid, {_key, _value} = data) do
    GenServer.call(pid, {:delete, data})
  end

  def handle_call({:put, {key, value} = data}, from, %__MODULE__{} = state) when is_tuple(data) do

   payload = Jason.encode!(%{key: Base.encode64(key), value: Base.encode64(value)})
   case make_request("POST", "/v3/kv/put", [], payload, state) do
      {:ok, state} ->

      {:noreply, put_in(state.from, from)}
      error ->
        {:reply, {:error, error}, state}
   end
  end

  defp make_request(request, path, headers, payload, %__MODULE__{} = state) do
    case Mint.HTTP.request(
           state.conn,
           request,
           path,
           headers,
          payload) do
      {:ok, conn, _} ->
        state = put_in(state.conn, conn)

        {:ok, state}

      error ->

        error
      end

  end


  def handle_info({:tcp, _port, _response} = message, state) do

    IO.puts "response"
    case Mint.HTTP.stream(state.conn, message) do
      {:ok, conn, responses} ->
        IO.puts "response"
        Enum.reduce(responses, state, &process_response/2)
        {:noreply, put_in(state.conn, conn)}

      {:error, _, _, _} ->
        {:noreply, state}
      :unknown ->
        {:noreply, state}

    end
  end


  def handle_info(message, state) do
    IO.inspect message
    {:noreply, state}
  end


  defp process_response({:headers, _, response_headers}, state) do
 put_in(state.response[:headers], response_headers)

  end
  defp process_response({:status, _, status}, state) do
    put_in(state.response[:status], status)


  end

  defp process_response({:data, _, data}, state) do
    put_in(state.response[:data], Jason.decode!(data))
  end

  defp process_response({:done, _}, state) do

    GenServer.reply(state.from, {:ok, state.response})
  end


  defp process_response(_, state) do
    state
  end


end
