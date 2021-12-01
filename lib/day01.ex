defmodule Adventofcode2021.Day01 do
  require Logger

  def solve_a(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")
    array = file |> String.split("\n")
    count_increases(array, -1, 0) # The -1 avoids incrementing the count on the first measurement
  end

  def solve_b(file) do
    Logger.debug("Solving problem b in #{__MODULE__}")
    array = file |> String.split("\n")
    count_increases_by_three(array, 0, {nil, nil, nil})
  end

  defp count_increases_by_three([], total, _measures) do
    total
  end

  defp count_increases_by_three([""], total, _measures) do
    total
  end

  defp count_increases_by_three(file, total, {a, b, nil}) do
    [head | tail] = file
    count_increases_by_three(tail, total, {String.to_integer(head), a, b})
  end

  defp count_increases_by_three(file, total, {a, b, c}) do
    [head | tail] = file
    if String.to_integer(head) + a + b > a + b + c do
      count_increases_by_three(tail, total + 1, {String.to_integer(head), a, b})
    else
      count_increases_by_three(tail, total, {String.to_integer(head), a, b})
    end
  end

  defp count_increases([], total, _latest_depth) do
    total
  end

  defp count_increases([""], total, _latest_depth) do
    total
  end

  defp count_increases(file, total, latest_depth) do
    [head | tail] = file
    if String.to_integer(head) > latest_depth do
      count_increases(tail, total + 1, String.to_integer(head))
    else
      count_increases(tail, total, String.to_integer(head))
    end
  end
end
