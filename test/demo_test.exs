defmodule DemoTest do
  use ExUnit.Case
  doctest Demo

  test "greets the world" do
    assert Demo.hello() == :ok
  end
end
