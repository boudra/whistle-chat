defmodule WhistleChat.ChatProgram do
  use Whistle.Program

  def init(_params) do
    {:ok, %{messages: [], users: []}}
  end

  def authorize(state, socket, %{"user" => user}) do
    {:ok, socket, %{input: "", user: user}}
  end

  # Update

  def update({:update_input, input}, state, session) do
    {:ok, state, %{session | input: input}}
  end

  def update(:submit_msg, state = %{messages: messages}, session = %{user: user, input: input}) do
    {:ok, %{state | messages: messages ++ [{user, input}]}, %{session | input: ""}}
  end

  def update({"update_input", input}, state, session) do
    {:ok, state, %{session | input: input}}
  end

  # Process Messages

  def handle_info({:connected, _, %{user: user}}, state = %{users: users}) do
    {:ok, %{state | users: users ++ [user]}}
  end

  def handle_info({:disconnected, _, %{user: user}}, state = %{users: users}) do
    new_users =
      Enum.reject(users, &(&1 == user))

    {:ok, %{state | users: new_users}}
  end

  def handle_info(message, state) do
    {:ok, state}
  end

  # View

  def view(state, session) do
    Html.div([style: "max-width: 400px; font-family: sans-serif;"], [
      view_connected_users(state[:users]),
      view_messages(state[:messages]),
      view_controls(session)
    ])
  end

  defp view_connected_users(users) do
    user_list =
      users
      |> Enum.map(&Html.text/1)
      |> Enum.intersperse(Html.text(", "))

    Html.div([style: "padding: 10px; background: #eee; box-shadow: 0px 1px 4px rgba(0,0,0,0.1); z-index: 2;"], [
      Html.strong([], "Connected users:"),
      Html.div([], user_list),
    ])
  end

  defp view_controls(%{user: user, input: input}) do
    Html.form([id: "form", on: [submit: :submit_msg]], [
      Html.node("hr", [], []),
      Html.p([], user <> ": "),
      Html.input(name: "msg", required: true, value: input, on: [input: &{:update_input, &1}]),
      Html.button([], "Send")
    ])
  end

  defp view_messages(messages) do
    Html.div([class: "messages", style: "overflow: auto; padding: 10px; background: #f7f7f7; max-height: 200px;"],
      Enum.map(messages, fn {user, msg} ->
        Html.p([], [
          Html.strong([], user <> ": "),
          Html.text(msg)
        ])
      end)
    )
  end
end
