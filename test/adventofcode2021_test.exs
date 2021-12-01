defmodule Adventofcode2021Test do
  use ExUnit.Case
  doctest Adventofcode2021

  test "day 01 sample" do
    sample = Adventofcode2021.read_sample("01")
    assert Adventofcode2021.Day01.solve(sample) == 7
  end

  test "day 01 input" do
    input = Adventofcode2021.read_input("01")
    output = Adventofcode2021.Day01.solve(input) |> Adventofcode2021.write_output("01")
    assert output == :ok
  end
end
