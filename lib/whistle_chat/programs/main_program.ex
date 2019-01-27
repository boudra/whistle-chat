defmodule WhistleChat.MainProgram do
  use Whistle.Program
  alias WhistleChat.MainView

  defmodule Room do
    defstruct messages: [{"whistlebot", "Welcome to the chat!"}]
  end

  defmodule State do
    defstruct users: %{}, rooms: %{"general" => %Room{}}
  end

  defmodule Session do
    defstruct [:route, :error, :user_id, :msg]
  end

  defp user_id() do
    :crypto.strong_rand_bytes(4)
    |> Base.encode32(case: :lower, padding: false)
  end

  ## Routes

  def route([], _state, session, _query_params) do
    {:ok, %{session | route: :index}}
  end

  def route(["chat", room_name], %{rooms: rooms}, session, _query_params) do
    if Map.has_key?(rooms, room_name) do
      {:ok, %{session | route: {:chat, room_name}}}
    else
      {:error, :not_found}
    end
  end

  def route(_route, _state, _session, _query_params) do
    {:error, :not_found}
  end

  ## Init

  def init(_params) do
    {:ok, %State{}}
  end

  def authorize(_state, socket, _params) do
    {:ok, socket, %Session{user_id: user_id(), route: :index}}
  end

  # Process Messages

  def handle_info({:connected, _, %{user_id: id}}, state = %{users: users}) do
    {:ok, %{state | users: Map.put(users, id, "anonymous")}}
  end

  def handle_info({:disconnected, _, %{user_id: id}}, state = %{users: users}) do
    {:ok, %{state | users: Map.delete(users, id)}}
  end

  ## Update

  def update({:change_username, %{"name" => name}}, state, session) do
    {:ok, %{state | users: Map.put(state.users, session.user_id, name)}, session}
  end

  def update({:change_msg, msg}, state, session) do
    {:ok, state, %{session | msg: msg}}
  end

  def update({:submit_msg, _room_name}, state, session = %{msg: ""}) do
    {:ok, state, %{session | error: "Please introduce a message"}}
  end

  def update({:submit_msg, room_name}, state, session) do
    case Map.fetch(state.rooms, room_name) do
      {:ok, room} ->
        new_room =
          Map.update!(room, :messages, fn messages ->
            messages ++ [{Map.get(state.users, session.user_id), session.msg}]
          end)

        {:ok, %{state | rooms: Map.put(state.rooms, room_name, new_room)}, %{ session | error: nil, msg: ""}}

      :error ->
        {:ok, state, session}
    end
  end

  def update({:create_room, %{"name" => name}}, state = %{rooms: rooms}, session) do
    cond do
      Map.size(rooms) >= 20 ->
        {:ok, state, %{session | error: "Whoops! We have reached the maximum number of rooms!"}}

      not Regex.match?(~r/^[a-z\-]{1,25}$/, name) ->
        {:ok, state,
         %{session | error: "Room names can only be in kebab-case and less than 25 chars"}}

      true ->
        {:ok, %{state | rooms: Map.put_new(rooms, name, %Room{})}, %{session | error: nil}}
    end
  end

  def update(_msg, state, session) do
    {:ok, state, session}
  end

  ## view

  def view(state, session = %{route: :index}) do
    MainView.index(state, session)
  end

  def view(state, session = %{route: {:chat, room}}) do
    MainView.chat(state, session, room)
  end
end
