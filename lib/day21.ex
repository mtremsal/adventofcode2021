defmodule GameState do
  defstruct p1: 1, p2: 1, s1: 0, s2: 0, last_roll: 0, total_rolls: 0, active_p: 1
end

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
end
