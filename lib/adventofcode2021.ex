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

  def write_output(content, day) do
    path = Path.expand(".") |> Path.join("/lib/day#{day}/output.txt")
    Logger.debug("Writing output file at: #{path}")
    write_output_safely(content, path)
  end

  defp write_output_safely(content, path) when is_list(content) or is_binary(content) do
    {:ok, f} = File.open(path, [:write])
    IO.binwrite(f, content)
  end

  defp write_output_safely(content, path) when is_integer(content) do
    {:ok, f} = File.open(path, [:write])
    IO.binwrite(f, Integer.to_string(content))
  end

  defp write_output_safely(content, path) do
    {:ok, f} = File.open(path, [:write])
    IO.binwrite(f, inspect content)
  end
end
