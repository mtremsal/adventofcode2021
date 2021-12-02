defmodule Adventofcode2021.Day02 do
  require Logger

  def solve_a(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")
    array = file |> String.split("\n")
    length(array)
  end
end
