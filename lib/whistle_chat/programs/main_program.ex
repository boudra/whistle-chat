defmodule WhistleChat.MainProgram do
  use Whistle.Program
  use Whistle.Navigation

 def init(_params) do
    {:ok, %{rooms: []}}
  end

  def authorize(state, socket, %{"user" => user, "path" => path}) do
    {:ok, socket, %{error: nil, name: user, path: path}}
  end

  def update({:change_username, %{"name" => name}}, state, session) do
    {:ok, state, %{session | name: name}}
  end

  def update({:create_room, _}, state = %{rooms: rooms}, session) when length(rooms) > 10 do
    {:ok, state, %{session | error: "Whoops! We have reached the maximum number of rooms!"}}
  end

  def update({:create_room, %{"name" => name}}, state = %{rooms: rooms}, session) do
    if Regex.match?(~r/^[a-z\-]{1,25}$/, name) do
      {:ok, %{state | rooms: [name | rooms]}, %{session | error: nil}}
    else
      {:ok, state, %{session | error: "Room names can only be in kebab-case and less than 25 chars"}}
    end
  end

  def update(msg, state, session) do
    {:ok, state, session}
  end

  def handle_info(msg, state) do
    {:ok, state}
  end

  def view_layout(title, main, error) do
    Navigation.html([lang: "en"], [
      Html.head([], [
        Html.meta(charset: "UTF-8"),
        Html.title(title),
        Html.script(src: "/js/whistle.js"),
        Html.link(
          rel: "stylesheet",
          href: "https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.css"
        )
      ]),
      Html.body([], [
        Html.div(
          [
            style: "min-height: 100vh",
            class: "ui inverted vertical masthead center aligned segment"
          ],
          [Html.div([class: "ui raised container segment"], [
            view_error(error) | main
          ])]
        )
      ])
    ])
  end

  def view_rooms(rooms) do
    Html.div(
      [class: "ui segments"],
      Enum.map(rooms, fn room ->
        Html.div([class: "ui segment"], [
          Navigation.link("/chat/#{room}", [], [
            Html.strong([], "#" <> room)
          ])
        ])
      end)
    )
  end

  def view(state, session = %{path: path}) do
    IEx.Helpers.r(__MODULE__)
    view(path, state, session)
  end

  def view_error(nil) do
    Html.div([], [])
  end

  def view_error(error) do
    Html.div([class: "ui negative message"], [
      Html.i(class: "close icon"),
      Html.div([class: "header"], "An error happened!"),
      Html.p([], to_string(error))
    ])
  end

  def view([], state, %{error: error, name: name}) do
    view_layout("Whistle Chat Demo", [
      Html.h1([class: "ui center aligned masthead"], "Welcome to the Whistle chat!"),
      Html.p([], """
      This web application is first rendered server side via a normal HTTP response,
      and then becomes a "dumb" client that dynamically patches the DOM with updates received via WebSockets.
      """),
      Html.p([], """
      The app state and view are automatically updated and broadcasted with Whistle. Presence is also tracked in the chat room.
      """),
      Html.p([], """
      You can change your username, create chat rooms and chat!
      """),
      Html.a([href: "https://github.com/boudra/whistle-chat"], "Check out the source code here"),
      Html.br(),
      Html.br(),
      Html.form([class: "ui small action input", on: [submit: &{:change_username, &1}]], [
        Html.input(type: "text", name: "name", value: name),
        Html.button([class: "ui button"], "Change username")
      ]),
      Html.br(),
      Html.br(),
      Html.div([], [
        Html.strong([], "List of available chat rooms:"),
        view_rooms(state.rooms)
      ]),
      Html.br(),
      Html.form([class: "ui action input", on: [submit: &{:create_room, &1}]], [
        Html.input(type: "text", name: "name", value: ""),
        Html.button([class: "ui button loading"], "Create a new room")
      ])
    ], error)
  end

  def view(["chat", room], state, %{name: name}) do
    view_layout("Room #" <> room, [
      Html.h1([class: "ui left"], "#" <> room),
      Navigation.link("/", [], "Homepage"),
      Html.program("chat:#{room}", %{"user" => name})
    ], nil)
  end

  def view(path, state, session) do
    view_layout("Not found", [
      Html.p([], "path /#{Enum.join(path, "/")} not found")
    ], nil)
  end
end
