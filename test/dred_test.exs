defmodule DredTest do
  use ExUnit.Case
  doctest Dred

  test "greets the world" do
    assert Dred.hello() == :world
  end
end
