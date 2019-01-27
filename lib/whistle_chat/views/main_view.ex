defmodule WhistleChat.MainView do
  require Whistle.Html
  alias Whistle.Html

  defp view_layout(title, main, error) do
    Html.html([lang: "en"], [
      Html.head([], [
        Html.meta(charset: "UTF-8"),
        Html.meta(name: "viewport", content: "width=device-width, initial-scale=1"),
        Html.title(title),
        Html.script(src: "/js/whistle.js"),
        Html.script(src: "/js/app.js"),
        Html.link(
          rel: "stylesheet",
          href: "https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.css"
        ),
        Html.link(
          rel: "stylesheet",
          href: "/css/main.css"
        )
      ]),
      Html.body([], [
        Html.div(
          [
            style: "min-height: 100vh",
            class: "ui inverted vertical masthead aligned segment"
          ],
          [
            Html.div([class: "ui raised container segment"], [
              view_error(error),
              main
            ])
          ]
        )
      ])
    ])
  end

  defp view_rooms(rooms) do
    Html.div(
      [class: "ui segments"],
      Enum.map(rooms, fn {room, _} ->
        Html.div([class: "ui segment"], [
          Html.ahref("/chat/#{room}", [], [
            Html.strong([], "#" <> room)
          ])
        ])
      end)
    )
  end

  defp view_error(nil) do
    Html.div([], [])
  end

  defp view_error(error) do
    Html.div([class: "ui negative message"], [
      Html.i(class: "close icon"),
      Html.div([class: "header"], "An error happened!"),
      Html.p([], to_string(error))
    ])
  end

  def index(state, %{error: error, user_id: id}) do
    user_name = Map.get(state.users, id)

    view_layout(
      "Whistle Chat Demo",
      Html.div([class: "ui stackable container grid", id: "one"], [
        Html.div([class: "six wide column"], [
          Html.h1([class: ""], "Welcome to the Whistle chat!"),
          Html.p([], """
          This web application is first rendered server side via in normal HTML,
          and then it becomes a "dumb" client that dynamically patches the DOM with updates received via WebSockets.
          """),
          Html.p([], """
          The app state, view and user presence are automatically updated and broadcasted with Whistle.
          """),
          Html.p([], """
          You can change your username, create chat rooms and chat!
          """),
          Html.a(
            [href: "https://github.com/boudra/whistle-chat"],
            "Check out the source code here"
          ),
          Html.br(),
          Html.br(),
          Html.form([class: "ui fluid small action input", on: [submit: &{:change_username, &1}]], [
            Html.input(type: "text", name: "name", value: user_name),
            Html.button([class: "ui button"], "Change username")
          ])
        ]),
        Html.div([class: "ten wide column"], [
          Html.form([class: "ui fluid action input", on: [submit: &{:create_room, &1}]], [
            Html.input(type: "text", name: "name", value: ""),
            Html.button([class: "ui button"], "Create a new room")
          ]),
          Html.br(),
          Html.br(),
          Html.div([], [
            Html.strong([], "List of available chat rooms:"),
            view_rooms(state.rooms)
          ])
        ])
      ]),
      error
    )
  end

  def user_list(users, current_user) do
    content =
      users
      |> Enum.map(fn {id, name} ->
        if id == current_user do
          Html.strong([], "#{name} (you)")
        else
          name
        end
      end)
      |> Enum.intersperse(", ")

    Html.div([], [
      Html.p([], "Connected users: "),
      Html.p(
        [class: "users"],
        content
      )
    ])
  end

  def room(%{messages: messages}) do
    Html.div(
      [class: "messages"],
      Enum.map(messages, fn {user, msg} ->
        Html.p([class: "message"], [
          Html.strong([], user),
          Html.text(": "),
          Html.text(msg)
        ])
      end)
    )
  end

  def chat(state, session, room) do
    view_layout(
      "Room #" <> room,
      Html.div([id: "two"], [
        user_list(state.users, session.user_id),
        Html.ahref("/", [], "Go back to the Homepage"),
        Html.h1([class: "ui left"], "#" <> room),
        room(Map.get(state.rooms, room)),
        Html.form([class: "fluid ui action input", on: [submit: {:submit_msg, room}]], [
          Html.input(
            type: "text",
            name: "msg",
            value: session.msg,
            on: [input: &{:change_msg, &1}]
          ),
          Html.button([class: "ui button"], "Submit")
        ]),
        view_error(session.error)
      ]),
      nil
    )
  end
end
