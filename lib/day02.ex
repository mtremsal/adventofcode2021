defmodule Adventofcode2021.Day02 do
  require Logger

  def solve_a(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")
    array = file |> String.split("\n")
    follow_planned_course(array, 0, 0)
  end

  defp follow_planned_course(plan, depth, position) do
    [head | tail] = plan

    case head do
      "forward " <> value ->
        follow_planned_course(tail, depth, position + String.to_integer(value))

      "up " <> value ->
        follow_planned_course(tail, depth - String.to_integer(value), position)

      "down " <> value ->
        follow_planned_course(tail, depth + String.to_integer(value), position)

      _ ->
        {depth, position}
    end
  end
end
