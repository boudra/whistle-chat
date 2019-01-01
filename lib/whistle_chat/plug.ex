defmodule WhistleChat.Plug do
  use Plug.Builder

  plug Plug.Logger

  plug Plug.Static,
    at: "/",
    from: :whistle_chat,
    gzip: false,
    only: ~w(css js favicon.ico robots.txt)

  plug :index

  def index(conn, _opts) do
    send_file(conn, 200, "priv/static/index.html")
  end
end
