defmodule WhistleChat.ProgramRouter do
  use Whistle.Router, path: "/ws"

  match("main", WhistleChat.MainProgram, %{})
end

