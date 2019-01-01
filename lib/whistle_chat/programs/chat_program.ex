defmodule WhistleChat.ChatProgram do
  use Whistle.Program

  def init(_params) do
    {:ok, %{messages: [], users: []}}
  end

  def authorize(state, socket, params) do
    user = "Anonymous" <> to_string(:rand.uniform(100))

    {:ok, socket, %{input: "", user: user}}
  end

  # Update

  def update({:update_input, input}, state, session) do
    {:ok, state, %{session | input: input}}
  end

  def update(:submit, state = %{messages: messages}, session = %{user: user, input: input}) do
    {:ok, %{state | messages: messages ++ [{user, input}]}, %{session | input: ""}}
  end

  # Process Messages

  def handle_info({:connected, _, %{user: user}}, state = %{users: users}) do
    {:ok, %{state | users: users ++ [user]}}
  end

  def handle_info({:disconnected, _, %{user: user}}, state = %{users: users}) do
    new_users =
      Enum.filter(users, &(&1 == user))

    {:ok, %{state | users: new_users}}
  end

  def handle_info(message, state) do
    {:ok, state}
  end

  # View

  def view(state, session) do
    Html.div([], [
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

    Html.div([], [
      Html.strong([], "Connected users:"),
      Html.div([], user_list),
      Html.node("hr", [], [])
    ])
  end

  defp view_controls(%{user: user, input: input}) do
    Html.form([on: [submit: :submit]], [
      Html.node("hr", [], []),
      Html.p([], user <> ": "),
      Html.input(required: true, value: input, on: [input: &{:update_input, &1}]),
      Html.button([], "Send")
    ])
  end

  defp view_messages(messages) do
    Html.div([style: %{"height" => "300px", "overflow" => "scroll"}],
      Enum.map(messages, fn {user, msg} ->
        Html.p([], [
          Html.strong([], user <> ": "),
          Html.text(msg)
        ])
      end)
    )
  end
end
