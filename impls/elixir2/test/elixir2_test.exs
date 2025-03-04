defmodule Elixir2Test do
  use ExUnit.Case
  doctest Elixir2

  test "greets the world" do
    assert Elixir2.hello() == :world
  end
end
