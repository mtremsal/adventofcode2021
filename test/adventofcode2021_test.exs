defmodule Adventofcode2021Test do
  use ExUnit.Case
  doctest Adventofcode2021

  test "day 01-a sample" do
    sample = Adventofcode2021.read_sample("01-a")
    assert Adventofcode2021.Day01.solve(sample) == 7
  end

  test "day 01-a input" do
    input = Adventofcode2021.read_input("01-a")
    output = Adventofcode2021.Day01.solve(input) |> Adventofcode2021.write_output("01-a")
    assert output == :ok
  end
end
