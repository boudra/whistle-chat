defmodule WhistleChat.Plug do
  use Plug.Builder

  plug(Plug.Logger)

  plug(Plug.Static,
    at: "/",
    from: :whistle_chat,
    gzip: false,
    only: ~w(css js favicon.ico robots.txt)
  )

  def log(conn, _opts) do
    IO.inspect(conn)
  end

  plug :log

  plug Plug.Parsers, parsers: [:urlencoded, :json],
    pass: ["text/*"],
    json_decoder: Jason

  plug(Whistle.Program.Plug,
    router: WhistleChat.ProgramRouter,
    program: "main"
  )
end
