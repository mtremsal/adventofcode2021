defmodule Adventofcode2021.Day12 do
  require Logger

  # Part a
  def solve_a(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")

    file
    |> String.split(["\n", "-"], trim: true)
    |> Enum.chunk_every(2)
    |> build_graph_from_segments()
    |> walk_until_complete(:part_a)
    # |> walk_n_times(20)
    # |> Enum.map(&Enum.reverse/1)
    |> Enum.count()
  end

  def solve_b(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")

    file
    |> String.split(["\n", "-"], trim: true)
    |> Enum.chunk_every(2)
    |> build_graph_from_segments()
    |> walk_until_complete(:part_b)
    # |> walk_n_times(20)
    # |> Enum.map(&Enum.reverse/1)
    |> Enum.count()
  end

  def build_graph_from_segments(segments) do
    segments
    |> Enum.reduce(%{}, fn x, acc ->
      start = Enum.at(x, 0)
      finish = Enum.at(x, 1)

      acc
      |> Map.update(start, [finish], fn value -> [finish] ++ value end)
      |> Map.update(finish, [start], fn value -> [start] ++ value end)
    end)
  end

  def path_complete?(["end" | _]), do: true
  def path_complete?(_), do: false

  def walk_n_times(graph, n, option) do
    walk_n_times([["start"]], graph, n, option)
  end

  def walk_n_times(paths, _graph, 0, _option), do: paths

  def walk_n_times(paths, graph, n, option) do
    walk_n_times(walk_once(paths, graph, option), graph, n - 1, option)
  end

  def walk_until_complete(graph, option) do
    walk_until_complete([["start"]], graph, option)
  end

  def walk_until_complete(paths, graph, option) do
    if Enum.all?(paths, &path_complete?/1) do
      paths
    else
      walk_until_complete(walk_once(paths, graph, option), graph, option)
    end
  end

  def walk_once(paths, graph, option) do
    paths
    |> Enum.map(fn path -> walk_a_path_once(path, graph, option) end)
    |> Enum.concat()
  end

  # Note: returning [["end"]] instead of the full path is a small memory optimization
  def walk_a_path_once(["end" | _rest_of_path], _graph, _option), do: [["end"]]

  def walk_a_path_once([node | rest_of_path] = path, graph, :part_a) do
    for target <- Map.fetch!(graph, node),
        target == "end" or
          String.upcase(target) == target or
          not Enum.member?(rest_of_path, target) do
      [target] ++ path
    end
  end

  # Part B
  def walk_a_path_once([node | rest_of_path] = path, graph, :part_b) do
    for target <- Map.fetch!(graph, node),
        target != "start" and
          (target == "end" or
             String.upcase(target) == target or
             not Enum.member?(rest_of_path, target) or
             max_visits_to_small_caves(path) < 2) do
      [target] ++ path
    end
  end

  def max_visits_to_small_caves(path) do
    (path -- ["start"])
    |> Enum.reject(fn node -> String.upcase(node) == node end)
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.max(&>=/2, fn -> 0 end)
  end
end
