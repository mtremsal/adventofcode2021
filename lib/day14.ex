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
      |> Enum.reduce(%{}, fn
        [pair | insertion], acc ->
          Map.put(acc, pair, Enum.at(insertion, 0))
      end)

    start
    |> sequence_to_pair_freqs()
    |> polymerize_n_times(instructions, 40)
    |> Enum.reduce(%{}, fn {<<a, _rest::binary>>, v}, acc ->
      acc |> Map.update(<<a>>, v, &(&1 + v))
    end)
    |> Map.values()
    |> Enum.min_max()
    |> then(&((&1 |> elem(1)) - (&1 |> elem(0))))
  end

  def sequence_to_pair_freqs(sequence) do
    sequence
    |> String.graphemes()
    # we append a useless 0 to the last char so we don't lose it in the count
    |> Enum.chunk_every(2, 1, [0])
    |> Enum.map(&Enum.join/1)
    |> Enum.reduce(%{}, fn pair, acc ->
      Map.update(acc, pair, 1, &(&1 + 1))
    end)
  end

  def polimerize_pair_freqs(pair_freqs, instructions) do
    pair_freqs
    |> Enum.reduce(pair_freqs, fn
      {key, val}, acc ->
        insert = Map.get(instructions, key)

        if insert do
          <<a, rest::binary>> = key

          acc
          |> Map.update(key, val, &(&1 - val))
          |> Map.update(<<a>> <> insert, val, &(&1 + val))
          |> Map.update(insert <> String.first(rest), val, &(&1 + val))
        else
          acc
        end
    end)
  end

  def polymerize_n_times(pair_freqs, instructions, n) do
    polymerize_n_times(pair_freqs, instructions, n, Time.utc_now())
  end

  def polymerize_n_times(pair_freqs, _instructions, 0, _timer), do: pair_freqs

  def polymerize_n_times(pair_freqs, instructions, n, timer) do
    # IO.puts("#{n} passes remaining. Last pass took #{Time.diff(Time.utc_now(), timer)}s.")

    polymerize_n_times(
      polimerize_pair_freqs(pair_freqs, instructions),
      instructions,
      n - 1,
      timer
    )
  end
end
