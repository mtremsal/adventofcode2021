defmodule Adventofcode2021.Day01 do
  require Logger

  def solve(file) do
    Logger.debug("Solving for #{__MODULE__}")
    array = file |> String.split("\n")
    count_increases(array, -1, 0) # The -1 avoids incrementing the count on the first measurement
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
