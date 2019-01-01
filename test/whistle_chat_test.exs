defmodule WhistleChatTest do
  use ExUnit.Case
  doctest WhistleChat

  test "greets the world" do
    assert WhistleChat.hello() == :world
  end
end
