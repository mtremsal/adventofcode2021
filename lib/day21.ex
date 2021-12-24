defmodule GameState do
  defstruct p1: 1, p2: 1, s1: 0, s2: 0, last_roll: 0, total_rolls: 0, active_p: 1
end

# Part a
defmodule DeterministicDiceAgent do
  use Agent

  require Logger

  def start_link(p1, p2) do
    Agent.start_link(fn -> %GameState{p1: p1, p2: p2} end, name: __MODULE__)
  end

  def play_a_game() do
    if score?() == 0 do
      send(self(), play_a_turn())

      receive do
        :ok -> play_a_game()
      end
    else
      score?()
    end
  end

  def play_a_turn() do
    roll_n_times(3) |> move_active_player()
    switch_active_player()
    :ok
  end

  def score?() do
    state = Agent.get(__MODULE__, fn state -> state end)

    if max(state.s1, state.s2) >= 1000 do
      if state.s1 >= 1000 do
        state.s2 * state.total_rolls
      else
        state.s1 * state.total_rolls
      end
    else
      0
    end
  end

  def get_active_player do
    Agent.get(__MODULE__, fn state -> state.active_p end)
  end

  def get_player_position_and_score(player) do
    if player == 1 do
      Agent.get(__MODULE__, fn state -> {state.p1, state.s1} end)
    else
      Agent.get(__MODULE__, fn state -> {state.p2, state.s2} end)
    end
  end

  def set_player_position_and_score(player, pos, score) do
    if player == 1 do
      Agent.update(__MODULE__, fn state ->
        state
        |> Map.put(:p1, pos)
        |> Map.put(:s1, score)
      end)
    else
      Agent.update(__MODULE__, fn state ->
        state
        |> Map.put(:p2, pos)
        |> Map.put(:s2, score)
      end)
    end
  end

  def switch_active_player do
    active_p = get_active_player()

    if active_p == 1 do
      Agent.update(__MODULE__, fn state -> %GameState{state | active_p: 2} end)
    else
      Agent.update(__MODULE__, fn state -> %GameState{state | active_p: 1} end)
    end

    Agent.get(__MODULE__, & &1.active_p)
  end

  defp new_pos(pos) when pos <= 10, do: pos
  defp new_pos(pos), do: new_pos(pos - 10)

  def move_active_player(distance) do
    active_p = get_active_player()
    {current_pos, current_score} = get_player_position_and_score(active_p)
    new_pos = new_pos(current_pos + distance)
    new_score = current_score + new_pos

    # Logger.debug("Moving player #{active_p} by #{distance} to position #{new_pos} with new score of #{new_score}")

    set_player_position_and_score(active_p, new_pos, new_score)
  end

  def roll() do
    last_roll = Agent.get(__MODULE__, fn state -> state.last_roll end)
    total_rolls = Agent.get(__MODULE__, fn state -> state.total_rolls end)

    new_roll =
      if last_roll == 100 do
        1
      else
        last_roll + 1
      end

    Agent.update(__MODULE__, fn state ->
      state
      |> Map.put(:last_roll, new_roll)
      |> Map.put(:total_rolls, total_rolls + 1)
    end)

    new_roll
  end

  def roll_n_times(0), do: 0

  def roll_n_times(n) do
    roll() + roll_n_times(n - 1)
  end

  def display() do
    state = Agent.get(__MODULE__, fn state -> state end)
    Logger.debug("P1 at #{state.p1} w/ score #{state.s1}.")
    Logger.debug("P2 at #{state.p2} w/ score #{state.s2}.")
    Logger.debug("#{state.total_rolls} total rolls so far, ending with #{state.last_roll}.")
  end
end

# Part b
defmodule DiracDiceCacheServer do
  use GenServer

  require Logger

  @name :dirac_dice

  # Server Callbacks

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{cache: %{}, cache_size: 0}, name: @name)
  end

  @impl true
  def init(params) do
    {:ok, params}
  end

  @impl true
  def handle_cast({:cache, key, result}, state) do
    if Map.get(state.cache, key) do
      {:noreply, state}
    else
      cache = Map.put(state.cache, key, result)
      cache_size = cache |> Enum.count()
      Logger.debug("#{cache_size} results after caching #{inspect(result)} at #{key}")
      {:noreply, %{state | cache: cache, cache_size: cache_size}}
    end
  end

  @impl true
  def handle_cast({:request, key}, state) do
    check = Map.get(state.cache, key)

    if !check do
      # Logger.debug("#{key} not found in cache")
      {p1, p2, s1, s2, active_p} = key_to_params(key)
      play_a_turn(%GameState{p1: p1, p2: p2, s1: s1, s2: s2, active_p: active_p}, state.cache)
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    result = Map.get(state.cache, key)

    if result do
      {:reply, {:ok, result}, state}
    else
      GenServer.cast(@name, {:request, key})
      {:reply, {:error, :notfound}, state}
    end
  end

  # Server functions

  def warmup() do
    for p1 <- 10..1//-1,
        p2 <- 10..1//-1,
        s1 <- 30..10//-1,
        s2 <- 30..10//-1,
        p_active <- 1..2 do
      GenServer.cast(@name, {:request, params_to_key(p1, p2, s1, s2, p_active)})
    end

    :ok
  end

  def state_to_key(state),
    do: params_to_key(state.p1, state.p2, state.s1, state.s2, state.active_p)

  def params_to_key(p1, p2, s1, s2, active_p),
    do: "#{p1}-#{p2}-#{s1}-#{s2}-#{active_p}"

  def key_to_params(key) do
    key
    |> String.split("-", trim: true)
    |> List.to_tuple()
  end

  # Game logic
  def play_a_turn(%GameState{} = game_state, cache_state) do
    game_state = clean_game_state(game_state)

    case won_by?(game_state) do
      :in_progress ->
        rolls = [3, 4, 5, 4, 5, 6, 5, 6, 7, 4, 5, 6, 5, 6, 7, 6, 7, 8, 5, 6, 7, 6, 7, 8, 7, 8, 9]
        unique_rolls = 3..9
        # for i <- [1, 2, 3],
        #     j <- [1, 2, 3],
        #     k <- [1, 2, 3] do
        #   i + j + k
        # end

        unique_results =
          unique_rolls
          |> Enum.map(&simulate_move(game_state, &1))
          |> Enum.map(&state_to_key/1)
          |> Enum.map(fn key -> {key, Map.get(cache_state, key)} end)

        if Enum.any?(unique_results, fn {_key, value} -> is_nil(value) end) do
          unique_results
          |> Enum.filter(fn {_key, value} -> is_nil(value) end)
          |> Enum.map(fn {key, _value} -> GenServer.cast(@name, {:request, key}) end)

          GenServer.cast(@name, {:request, state_to_key(game_state)})
        else
          result =
            rolls
            |> Enum.map(&simulate_move(game_state, &1))
            |> Enum.map(&state_to_key/1)
            |> Enum.map(fn key -> {key, Map.get(cache_state, key)} end)
            |> Enum.map(&elem(&1, 1))
            |> sum_results()

          GenServer.cast(@name, {:cache, state_to_key(game_state), result})
        end

      result ->
        GenServer.cast(@name, {:cache, state_to_key(game_state), result})
        result
    end
  end

  def clean_game_state(game_state) do
    game_state
    |> Map.put(:p1, String.to_integer(game_state.p1))
    |> Map.put(:p2, String.to_integer(game_state.p2))
    |> Map.put(:s1, String.to_integer(game_state.s1))
    |> Map.put(:s2, String.to_integer(game_state.s2))
    |> Map.put(:active_p, String.to_integer(game_state.active_p))
  end

  def sum_results(array) do
    array
    |> Enum.reduce({0, 0}, fn
      # {1, 0}, {t1, t2} -> {t1 + 1, t2}
      # {0, 1}, {t1, t2} -> {t1, t2 + 1}
      {x, y}, {t1, t2} -> {t1 + x, t2 + y}
    end)
  end

  def won_by?(game_state) do
    if game_state.s1 >= 21 or game_state.s2 >= 21 do
      # We check for won games after the turn, meaning the active player has switched
      if game_state.active_p == 1 do
        {0, 1}
      else
        {1, 0}
      end
    else
      :in_progress
    end
  end

  def simulate_move(game_state, distance) do
    if game_state.active_p == 1 do
      new_pos = new_pos(game_state.p1 + distance)

      game_state
      |> Map.put(:p1, new_pos)
      |> Map.put(:s1, game_state.s1 + new_pos)
      |> Map.put(:active_p, 2)
    else
      new_pos = new_pos(game_state.p2 + distance)

      game_state
      |> Map.put(:p2, new_pos)
      |> Map.put(:s2, game_state.s2 + new_pos)
      |> Map.put(:active_p, 1)
    end
  end

  defp new_pos(pos) when pos <= 10, do: pos
  defp new_pos(pos), do: new_pos(pos - 10)
end

defmodule Adventofcode2021.Day21 do
  require Logger

  # Part a
  def solve_a(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")

    {p1, p2} =
      file
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.at(line, -1)
        |> String.to_integer()
      end)
      |> then(&{&1 |> Enum.at(0), &1 |> Enum.at(1)})

    {:ok, game} = DeterministicDiceAgent.start_link(p1, p2)
    Logger.debug("Starting DeterministicDiceAgent with pid: #{inspect(game)}")
    DeterministicDiceAgent.play_a_game()
  end

  # Part b
  def solve_b(file) do
    Logger.debug("Solving problem b in #{__MODULE__}")

    # {p1, p2} =
    file
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.at(line, -1)
      |> String.to_integer()
    end)
    |> then(&{&1 |> Enum.at(0), &1 |> Enum.at(1)})

    # {:ok, pid} = DiracDiceCacheServer.start_link []
    # DiracDiceCacheServer.warmup()

    # GenServer.call(:dirac_dice, {:get, "4-8-0-0-1"})
    # GenServer.call(:dirac_dice, {:get, "1-5-0-0-1"})

    # :sys.get_state(pid)
    # :sys.get_status(pid)
  end
end
