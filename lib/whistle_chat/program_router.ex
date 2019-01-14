defmodule WhistleChat.ProgramRouter do
  use Whistle.Router, path: "/ws"

  match("chat:*room", WhistleChat.ChatProgram, %{})
  match("main", WhistleChat.MainProgram, %{})
end

