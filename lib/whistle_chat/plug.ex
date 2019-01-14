defmodule WhistleChat.Plug do
  use Plug.Builder

  defp index_html(conn) do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title></title>
    </head>
    <body>
      #{}
      <script src="/js/whistle.js"></script>
    </body>
    </html>
    """
  end

  plug Plug.Logger

  plug Plug.Static,
    at: "/",
    from: :whistle_chat,
    gzip: false,
    only: ~w(css js favicon.ico robots.txt)

  plug :index

  @adjectives ~w(Magical Quiet Happy Hungry)
  @animals ~w(Llama Badger Bear Lion Cat)

  def index(conn, _opts) do
    user =
      Enum.join([Enum.random(@adjectives), Enum.random(@animals), to_string(:rand.uniform(100))])

    resp =
      Whistle.Program.fullscreen(
        conn,
        WhistleChat.ProgramRouter,
        "main",
        %{"user" => user, "path" => conn.path_info}
      )

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, resp)
  end
end
