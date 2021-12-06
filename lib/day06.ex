defmodule Adventofcode2021.Day06 do
  require Logger

  # Part a
  def solve_a(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")

    init_school =
      file
      |> String.trim("\n")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    1..80
    |> Enum.reduce(init_school, fn _gen, school -> age_the_school(school) end)
    |> length
  end

  def solve_b(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")

    init_school_freqs =
      file
      |> String.trim("\n")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.frequencies()

    1..256
    |> Enum.reduce(init_school_freqs, fn _gen, school_freqs ->
      age_the_school_frequencies(school_freqs)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def age_a_fish(0), do: [6, 8]
  def age_a_fish(age), do: [age - 1]

  def age_the_school(school) do
    Logger.debug("School length: #{inspect(length(school))}")
    school |> Enum.reduce([], fn fish, acc -> age_a_fish(fish) ++ acc end)
  end

  def age_the_school_frequencies(freqs) do
    freqs_0 = select_int_safely(freqs[0])

    freqs
    |> Map.delete(0)
    |> Enum.map(fn {k, v} -> {k - 1, v} end)
    |> Enum.into(%{})
    |> Map.put(8, freqs_0)
    |> Map.put(6, freqs_0 + select_int_safely(freqs[7]))
  end

  def select_int_safely(value) when is_nil(value), do: 0
  def select_int_safely(value), do: value
end
