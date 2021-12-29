defmodule Node do
  defstruct id: nil, contains: nil, links: [], expects: nil, can_stop?: true
end

defmodule Adventofcode2021.Day23 do
  require Logger

  # Part a

  def solve_a(file) do
    file
    |> String.replace([" ", "#", ".", "\n"], "")
    |> init_maze()
    |> then(&step([{&1, 0}], 20000))
  end

  def empty_maze() do
    %{
      1 => %Node{id: 1, links: [2]},
      2 => %Node{id: 2, links: [1, 3]},
      3 => %Node{id: 3, links: [2, 4, 103], can_stop?: false},
      4 => %Node{id: 4, links: [3, 5]},
      5 => %Node{id: 5, links: [4, 6, 105], can_stop?: false},
      6 => %Node{id: 6, links: [5, 7]},
      7 => %Node{id: 7, links: [6, 8, 107], can_stop?: false},
      8 => %Node{id: 8, links: [7, 9]},
      9 => %Node{id: 9, links: [8, 10, 109], can_stop?: false},
      10 => %Node{id: 10, links: [9, 11]},
      11 => %Node{id: 11, links: [10]},
      103 => %Node{id: 103, expects: "A", links: [3, 203]},
      203 => %Node{id: 203, expects: "A", links: [103]},
      105 => %Node{id: 105, expects: "B", links: [5, 205]},
      205 => %Node{id: 205, expects: "B", links: [105]},
      107 => %Node{id: 107, expects: "C", links: [7, 207]},
      207 => %Node{id: 207, expects: "C", links: [107]},
      109 => %Node{id: 109, expects: "D", links: [9, 209]},
      209 => %Node{id: 209, expects: "D", links: [109]}
    }
  end

  def init_maze(string) do
    starting_keys =
      empty_maze()
      |> Map.keys()
      |> Enum.filter(&(&1 > 100))
      |> Enum.sort()

    init_maze(empty_maze(), starting_keys, string)
  end

  def init_maze(maze, [], ""), do: maze

  def init_maze(maze, [key | keys], <<letter, letters::binary>>) do
    init_maze(
      Map.update!(maze, key, fn node -> %Node{node | contains: <<letter>>} end),
      keys,
      letters
    )
  end

  def fingerprint(maze) do
    keys =
      maze
      |> Map.keys()
      |> Enum.sort()

    for key <- keys do
      maze |> Map.fetch!(key) |> Map.get(:contains)
    end
    |> Enum.map(fn
      nil -> " "
      a -> a
    end)
    |> Enum.join()
  end

  def step([], min_score), do: min_score

  def step(states, min_score) do
    new_states =
      states
      |> Enum.sort_by(fn {maze, _cost} -> correct_keys(maze) |> Enum.count() end, :desc)
      |> Enum.take(10000)
      |> Enum.map(fn {maze, cost} -> legal_moves(maze, cost) end)
      |> Enum.concat()

    backlog =
      (new_states ++ states)
      |> Enum.reject(fn {_maze, cost} -> cost > min_score end)
      |> Enum.sort_by(fn {_maze, cost} -> cost end, :asc)
      |> Enum.uniq_by(fn {maze, _cost} -> fingerprint(maze) end)

    Logger.debug(
      "Stepping through #{Enum.count(new_states)} out of #{Enum.count(states)} states. Min score is: #{min_score}."
    )

    winners? =
      new_states
      |> Enum.filter(fn {maze, _cost} -> winning?(maze) end)

    losers =
      backlog
      |> Enum.reject(fn {maze, _cost} -> winning?(maze) end)

    if winners? |> Enum.any?() do
      step(
        losers,
        min(min_score, winners? |> Enum.map(fn {_maze, score} -> score end) |> Enum.min())
      )
    else
      step(backlog, min_score)
    end
  end

  def quick_step([], min_score), do: min_score

  def quick_step(states, min_score) do
    states_by_solves =
      states
      |> Enum.group_by(fn {maze, _cost} -> correct_keys(maze) |> Enum.count() end)

    solves = states_by_solves |> Map.keys() |> Enum.max()

    best_group =
      states_by_solves
      |> Map.fetch!(solves)

    other_groups =
      states_by_solves
      |> Map.delete(solves)
      |> Map.values()
      |> Enum.concat()
      |> Enum.reject(fn {_maze, cost} -> cost > min_score end)

    new_states =
      best_group
      |> Enum.map(fn {maze, cost} -> legal_moves(maze, cost) end)
      |> Enum.concat()
      |> Enum.reject(fn {_maze, cost} -> cost > min_score end)

    Logger.debug(
      "Stepping through #{Enum.count(new_states)} out of #{Enum.count(states)} states. Min score is: #{min_score}."
    )

    winners? =
      new_states
      |> Enum.filter(fn {maze, _cost} -> winning?(maze) end)

    losers =
      new_states
      |> Enum.reject(fn {maze, _cost} -> winning?(maze) end)

    if winners? |> Enum.any?() do
      quick_step(
        losers ++ other_groups,
        min(min_score, winners? |> Enum.map(fn {_maze, score} -> score end) |> Enum.min())
      )
    else
      quick_step(new_states ++ other_groups, min_score)
    end
  end

  def legal_moves(maze, cost) do
    solved_keys = correct_keys(maze)

    starting_nodes =
      maze
      |> Map.reject(fn {_key, node} -> is_nil(node.contains) end)
      |> Map.reject(fn {key, _node} -> Enum.member?(solved_keys, key) end)

    starting_nodes
    |> Map.keys()
    |> Enum.map(fn key -> legal_moves(maze, cost, key) end)
    |> Enum.concat()
  end

  def legal_moves(maze, cost, key) do
    starting_node = Map.fetch!(maze, key)
    letter = starting_node.contains

    potential_destinations =
      maze
      |> Map.filter(fn {_key, target} -> is_nil(target.contains) end)
      |> Map.filter(fn {_key, target} -> target.can_stop? end)
      # goes into the hallway or their own room
      |> Map.filter(fn {_key, target} ->
        is_nil(target.expects) or target.expects == letter
      end)
      # cannot move within the hallway
      |> Map.filter(fn {key, _target} -> key > 100 or starting_node.id > 100 end)
      |> Map.filter(fn {_key, target} -> can_reach?(maze, starting_node, target) end)
      |> Map.keys()

    # TODO: Must move to the back of the room if possible

    for dest <- potential_destinations do
      new_maze =
        maze
        |> Map.update!(key, fn node -> %Node{node | contains: nil} end)
        |> Map.update!(dest, fn node -> %Node{node | contains: letter} end)

      new_cost = cost + energy_cost(maze, key, dest)
      {new_maze, new_cost}
    end
  end

  def can_reach?(maze, from_node, to_node) do
    # Run sanity checks on to_node first, then check for path
    is_nil(to_node.contains) and
      to_node.can_stop? and
      can_reach?(maze, from_node, to_node, [from_node])
  end

  def can_reach?(maze, from_node, to_node, explored) do
    new_neighbors =
      maze
      |> Map.filter(fn {key, _node} -> Enum.member?(from_node.links -- explored, key) end)
      |> Map.filter(fn {_key, node} -> is_nil(node.contains) end)
      |> Map.keys()

    # to_node is a close neighbor, empty, and
    # or to_node is a neighbor of a neighbor
    Enum.member?(new_neighbors, to_node.id) or
      Enum.any?(new_neighbors, fn key ->
        can_reach?(maze, Map.fetch!(maze, key), to_node, new_neighbors ++ explored)
      end)
  end

  def energy_cost(maze, from_node_id, to_node_id) do
    unit_cost =
      case maze |> Map.fetch!(from_node_id) |> then(& &1.contains) do
        "A" -> 1
        "B" -> 10
        "C" -> 100
        "D" -> 1000
      end

    distance(maze, [from_node_id], to_node_id) * unit_cost
  end

  defp distance(maze, explored_nodes, to_node_id) do
    neighbors =
      explored_nodes
      |> Enum.map(fn key -> Map.fetch!(maze, key) end)
      |> Enum.map(fn node -> node.links end)
      |> Enum.concat()

    if Enum.member?(neighbors, to_node_id) do
      1
    else
      1 + distance(maze, neighbors, to_node_id)
    end
  end

  def winning?(maze) do
    maze
    |> Map.keys()
    |> Enum.filter(&(&1 > 100))
    |> Enum.map(fn key ->
      node = Map.fetch!(maze, key)
      node.expects == node.contains
    end)
    |> Enum.all?()
  end

  # ugly, stupid code
  def correct_keys(maze) do
    backroom_map =
      [203, 205, 207, 209]
      |> Enum.map(fn key ->
        maze |> Map.fetch!(key) |> then(&{&1.id, &1.contains == &1.expects})
      end)
      |> Enum.into(%{})

    frontroom_map =
      [103, 105, 107, 109]
      |> Enum.map(fn key ->
        maze |> Map.fetch!(key) |> then(&{&1.id, &1.contains == &1.expects})
      end)
      |> Enum.into(%{})
      |> Map.map(fn
        {_key, false} -> false
        {103, true} -> Map.fetch!(backroom_map, 203)
        {105, true} -> Map.fetch!(backroom_map, 205)
        {107, true} -> Map.fetch!(backroom_map, 207)
        {109, true} -> Map.fetch!(backroom_map, 209)
      end)

    Map.merge(backroom_map, frontroom_map)
    |> Map.filter(fn {_key, value} -> value end)
    |> Map.keys()
  end

  def display(maze) do
    array =
      for row <- -100..300//100 do
        for col <- 0..12 do
          case Map.get(maze, row + col) do
            result when is_nil(result) -> "#"
            %Node{contains: nil} -> "."
            %Node{contains: letter} -> letter
            _ -> "?"
          end
        end
      end
      |> Enum.intersperse("\n")
      |> Enum.join()

    Logger.debug("Maze is:\n" <> array)
  end
end
