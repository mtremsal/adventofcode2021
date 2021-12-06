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
      |> Enum.map(fn age -> {age, 6} end)

    1..80
    |> Enum.reduce(init_school, fn _gen, school -> age_the_school(school) end)
    |> length
  end

  # def age_a_fish({0, max_age}), do: [{max_age, max_age}, {max_age + 2, max_age + 2}]
  def age_a_fish({0, 6}), do: [{6, 6}, {8, 8}]
  def age_a_fish({0, 8}), do: [{6, 6}, {8, 8}]
  def age_a_fish({age, max_age}), do: [{age - 1, max_age}]

  def age_the_school(school) do
    Logger.debug("School length: #{inspect(length(school))}")
    school |> Enum.reduce([], fn fish, acc -> acc ++ age_a_fish(fish) end)
  end
end
