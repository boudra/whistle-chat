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
      #{Whistle.Program.mount(conn, WhistleChat.ProgramRouter, "chat", %{})}
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

  def index(conn, _opts) do
    IO.inspect {conn}

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, index_html(conn))
  end
end
