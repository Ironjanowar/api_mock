defmodule ApiMockTest do
  use ExUnit.Case
  doctest ApiMock

  test "greets the world" do
    assert ApiMock.hello() == :world
  end
end
