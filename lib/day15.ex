defmodule Adventofcode2021.Day15 do
  require Logger

  # Part a: see day15.livemd

  # Part b
  def solve_b(file) do
    Logger.debug("Solving problem b in #{__MODULE__}")

    risk_grid =
      file
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(fn row -> Enum.map(row, &String.to_integer/1) end)

    {x_max, y_max} = dimensions(risk_grid)

    expanded_risk_grid =
      for j <- 0..4,
          y <- 0..y_max do
        for i <- 0..4,
            x <- 0..x_max do
          risk_grid
          |> get(x, y)
          |> then(&(&1 + i + j))
          |> then(fn
            x when x > 9 -> x - 9
            x -> x
          end)
        end
      end

    expanded_risk_grid
    |> initialize_score_map()
    |> optimize_score_map_until_stable(expanded_risk_grid)
    |> display()
    |> Enum.at(-1)
    |> Enum.at(-1)
  end

  def dimensions(grid) do
    {length(grid |> Enum.at(0)) - 1, length(grid) - 1}
  end

  def get(grid, x, y) do
    grid |> Enum.at(y) |> Enum.at(x)
  end

  def valid_neighbors(grid, x, y) do
    {x_max, y_max} = dimensions(grid)

    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.map(fn {i, j} -> {i + x, j + y} end)
    |> Enum.reject(fn {i, j} -> i < 0 or i > x_max or j < 0 or j > y_max end)
  end

  def optimize_score_map_until_stable(score_map, risk_grid) do
    optimize_score_map_until_stable(score_map, risk_grid, :math.pow(10, 10))
  end

  def optimize_score_map_until_stable(score_map, risk_grid, total_score) do
    new_score_map = optimize_score_map(score_map, risk_grid)

    best_path =
      new_score_map
      |> display()
      |> Enum.at(-1)
      |> Enum.at(-1)

    Logger.debug("Current score is: #{total_score}")
    Logger.debug("Best path currently at: #{best_path}")

    new_total_score =
      new_score_map
      |> display
      |> Enum.concat()
      |> Enum.sum()

    if new_total_score < total_score do
      # IO.puts("current score is: #{new_total_score}")
      optimize_score_map_until_stable(new_score_map, risk_grid, new_total_score)
    else
      new_score_map
    end
  end

  def optimize_score_map(score_map, risk_grid) do
    {x_max, y_max} = dimensions(risk_grid)

    for j <- 0..y_max,
        i <- 0..x_max do
      {i, j}
    end
    |> Enum.reduce(score_map, fn {x, y} = key, acc ->
      new_min =
        min(
          get(risk_grid, x, y) + local_minimum_score(score_map, risk_grid, x, y),
          Map.fetch!(score_map, key)
        )

      Map.put(acc, key, new_min)
    end)
  end

  def initialize_score_map(risk_grid) do
    {x_max, y_max} = dimensions(risk_grid)

    start_map = Map.put(%{}, {0, 0}, 0)

    for j <- 0..y_max,
        i <- 0..x_max do
      {i, j}
    end
    # Don't reduce the entry point
    |> Enum.slice(1..-1)
    |> Enum.reduce(start_map, fn {x, y} = key, acc ->
      Map.put(acc, key, get(risk_grid, x, y) + local_minimum_score(acc, risk_grid, x, y))
    end)
  end

  def local_minimum_score(score_map, risk_grid, x, y) do
    local_scores =
      valid_neighbors(risk_grid, x, y)
      |> Enum.map(fn key ->
        Map.get(score_map, key)
      end)

    if Enum.any?(local_scores) do
      local_scores |> Enum.min()
    else
      0
    end
  end

  def display(score_map) do
    {x_max, y_max} =
      score_map
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn {x, y}, {i, j} -> {max(x, i), max(y, j)} end)

    for j <- 0..y_max do
      for i <- 0..x_max do
        Map.get(score_map, {i, j}, 0)
      end
    end
  end
end
