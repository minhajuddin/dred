defmodule Dred do

  require Record
  Record.defrecord Search, [id: nil, data: nil]

  # initializes the db
  def init() do
    set_db_dir()
    :mnesia.create_schema(db_nodes()) |> IO.inspect(label: "SCHEMA")
    :ok = :mnesia.start
    :mnesia.create_table(Search, [
      attributes: [:id, :data],
      disc_copies:  db_nodes(),
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
