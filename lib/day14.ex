defmodule Adventofcode2021.Day14 do
  require Logger

  # Part a: see day14.livemd

  # Part b
  def solve_b(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")

    [start | instructions] =
      file
      |> String.split("\n\n", trim: true)

    instructions =
      instructions
      |> Enum.at(0)
      |> String.split(["\n", " -> "], trim: true)
      |> Enum.chunk_every(2)
      |> Enum.reduce(%{}, fn [pair | insertion], acc ->
        Map.put(acc, pair, Enum.at(insertion, 0))
      end)

    start
    |> polymerize_n_times(instructions, 20)
    |> String.graphemes()
    |> Enum.frequencies()
    |> Map.values()
    |> then(fn freqs -> Enum.max(freqs) - Enum.min(freqs) end)
  end

  def polymerize_n_times(sequence, instructions, n) do
    polymerize_n_times(sequence, instructions, n, Time.utc_now())
  end

  def polymerize_n_times(sequence, _instructions, 0, _timer), do: sequence

  def polymerize_n_times(sequence, instructions, n, timer) do
    IO.puts(
      "#{n} passes remaining. Last pass took #{Time.diff(Time.utc_now(), timer, :microsecond)} ms."
    )

    polymerize_n_times(
      polymerize_v2(sequence, instructions),
      instructions,
      n - 1,
      Time.utc_now()
    )
  end

  # Hopefully smarter implementation that keeps the stack only as big as the string itself
  def polymerize_v2(sequence, instructions) do
    polimerize_single_pair(sequence, instructions, "")
  end

  def polimerize_single_pair(
        <<single>>,
        _instructions,
        processed_sequence
      ) do
    processed_sequence <> <<single>>
  end

  def polimerize_single_pair(
        <<pair::binary-size(2), rest::binary>>,
        instructions,
        processed_sequence
      ) do
    insertion = Map.get(instructions, pair, "")
    <<left, right::binary>> = pair

    polimerize_single_pair(
      right <> rest,
      instructions,
      processed_sequence <> <<left>> <> insertion
    )
  end

  # Naive implementation that requires a huge stack
  def polymerize_v1(sequence, instructions) do
    sequence
    |> String.graphemes()
    |> Enum.chunk_every(2, 1)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(fn
      <<a>> ->
        <<a>> <> <<a>>

      <<a, rest::binary>> = pair ->
        if Map.has_key?(instructions, pair) do
          <<a>> <> Map.fetch!(instructions, pair) <> rest
        else
          pair
        end
    end)
    |> Enum.map(fn string -> String.slice(string, 0..-2) end)
    |> Enum.join()
  end
end
