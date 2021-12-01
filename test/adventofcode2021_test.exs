defmodule Adventofcode2021Test do
  use ExUnit.Case
  doctest Adventofcode2021

  test "day 01 sample" do
    sample = Adventofcode2021.read_sample("01")
    assert Adventofcode2021.Day01.solve(sample) == 7
  end
end
