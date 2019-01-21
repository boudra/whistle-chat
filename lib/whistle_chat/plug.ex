defmodule WhistleChat.Plug do
  use Plug.Builder

  plug(Plug.Logger)

  plug(Plug.Static,
    at: "/",
    from: :whistle_chat,
    gzip: false,
    only: ~w(css js favicon.ico robots.txt)
  )

  plug(Whistle.Navigation.Plug,
    router: WhistleChat.ProgramRouter,
    program: "counter",
    params: %{}
  )

  @adjectives ~w(Magical Quiet Happy Hungry)
  @animals ~w(Llama Badger Bear Lion Cat)

  def index(conn, _opts) do
    user =
      Enum.join([Enum.random(@adjectives), Enum.random(@animals), to_string(:rand.uniform(100))])

    conn
    |> Whistle.Program.fullscreen(
      WhistleChat.ProgramRouter,
      "main",
      %{"user" => user, "path" => conn.path_info}
    )
  end
end
