defmodule Dred do

  require Record
  Record.defrecord Search, [id: nil, data: nil]

  # initializes the db
  def init(nodes \\ db_nodes()) do
    nodes |> Enum.map(fn n -> Node.connect(n) end) |> IO.inspect(label: "NODES")
    set_db_dir()
    :mnesia.create_schema(nodes) |> IO.inspect(label: "SCHEMA")
    :rpc.multicall(nodes, :mnesia, :start, []) |> IO.inspect(label: "START")
  end

  # call this after doing init
  def create_tables(nodes \\ db_nodes()) do
    :mnesia.create_table(Search, [
      attributes: [:id, :data],
      disc_copies:  nodes,
      type: :set, # :ordered_set, :bag
    ]) |> IO.inspect(label: "TABLE")
  end

  def put(search_id, data) do
    :mnesia.transaction(fn ->
      :mnesia.write({Search, search_id, data})
    end)
  end

  def get(search_id) do
    :mnesia.transaction(fn ->
      :mnesia.read(Search, search_id)
    end)
  end

  # TODO: make this dynamic so that it can connect to other nodes
  defp db_nodes do
    Application.get_env(:dred, :nodes) || [node()]
  end

  defp set_db_dir(dir \\ nil) do
    dir = dir || Path.expand("./db/")
    Application.put_env(:mnesia, :dir, dir |> to_charlist)
  end
end
