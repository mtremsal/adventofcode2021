defmodule Adventofcode2021 do
  @moduledoc """
  Shared functions for `Adventofcode2021`.
  """

  require Logger

  def read_sample(day) do
    path = Path.expand(".") |> Path.join("/lib/day#{day}/sample.txt")
    Logger.debug("Opening sample file at: #{path}")
    {:ok, f} = File.read(path)
    f
  end

  def read_input(day) do
    path = Path.expand(".") |> Path.join("/lib/day#{day}/input.txt")
    Logger.debug("Opening input file at: #{path}")
    {:ok, f} = File.read(path)
    f
  end
end
