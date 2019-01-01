defmodule WhistleChat.ProgramRouter do
  use Whistle.Router
  match("counter", WhistleChat.ChatProgram, %{})
end
