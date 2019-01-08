defmodule WhistleChat.ProgramRouter do
  use Whistle.Router, path: "/ws"

  match("chat", WhistleChat.ChatProgram, %{})
end

