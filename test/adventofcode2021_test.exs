defmodule Adventofcode2021Test do
  use ExUnit.Case
  doctest Adventofcode2021

  require Logger

  test "day 01-a sample" do
    sample = Adventofcode2021.read_sample("01-a")
    assert Adventofcode2021.Day01.solve_a(sample) == 7
  end

  test "day 01-a input" do
    input = Adventofcode2021.read_input("01-a")
    output = Adventofcode2021.Day01.solve_a(input) |> Adventofcode2021.write_output("01-a")
    assert output == :ok
  end

  test "day 01-b sample" do
    sample = Adventofcode2021.read_sample("01-b")
    assert Adventofcode2021.Day01.solve_b(sample) == 5
  end

  test "day 01-b input" do
    input = Adventofcode2021.read_input("01-b")
    output = Adventofcode2021.Day01.solve_b(input) |> Adventofcode2021.write_output("01-b")
    assert output == :ok
  end

  test "day 02-a sample" do
    sample = Adventofcode2021.read_sample("02-a")
    {depth, position} = Adventofcode2021.Day02.solve_a(sample)
    assert depth * position == 150
  end

  test "day 02-a input" do
    input = Adventofcode2021.read_input("02-a")
    output = Adventofcode2021.Day02.solve_a(input) |> Adventofcode2021.write_output("02-a")
    assert output == :ok
  end

  test "day 02-b sample" do
    sample = Adventofcode2021.read_sample("02-b")
    {depth, position} = Adventofcode2021.Day02.solve_b(sample)
    assert depth * position == 900
  end

  test "day 02-b input" do
    input = Adventofcode2021.read_input("02-b")
    output = Adventofcode2021.Day02.solve_b(input) |> Adventofcode2021.write_output("02-b")
    assert output == :ok
  end

  test "day 03-a sample" do
    result =
      Adventofcode2021.read_sample("03-a")
      |> Adventofcode2021.Day03.solve_a()

    {gamma, epsilon} = result
    assert gamma * epsilon == 198
  end

  test "day 03-a input" do
    output =
      Adventofcode2021.read_input("03-a")
      |> Adventofcode2021.Day03.solve_a()
      # |> then(fn {a, b} -> a * b end)
      |> Adventofcode2021.write_output("03-a")

    assert output == :ok
  end

  test "day 03-b sample" do
    result =
      Adventofcode2021.read_sample("03-b")
      |> Adventofcode2021.Day03.solve_b()

    {o2, co2} = result
    assert o2 * co2 == 230
  end

  test "day 03-b input" do
    output =
      Adventofcode2021.read_input("03-b")
      |> Adventofcode2021.Day03.solve_b()
      |> Adventofcode2021.write_output("03-b")

    assert output == :ok
  end

  test "day 06-a sample" do
    result =
      Adventofcode2021.read_sample("06-a")
      |> Adventofcode2021.Day06.solve_a()
    assert result == 5934
  end

  @tag timeout: :infinity
  test "day 06-a input" do
    output =
      Adventofcode2021.read_input("06-a")
      |> Adventofcode2021.Day06.solve_a()
      |> Adventofcode2021.write_output("06-a")

    assert output == :ok
  end

  test "day 06-b sample" do
    result =
      Adventofcode2021.read_sample("06-b")
      |> Adventofcode2021.Day06.solve_b()
    assert result == 26984457539
  end

  test "day 06-b input" do
    output =
      Adventofcode2021.read_input("06-b")
      |> Adventofcode2021.Day06.solve_b()
      |> Adventofcode2021.write_output("06-b")

    assert output == :ok
  end

  test "day 12-a sample" do
    result =
      Adventofcode2021.read_sample("12-a")
      |> Adventofcode2021.Day12.solve_a()
    assert result == 226
  end

  test "day 12-a input" do
    output =
      Adventofcode2021.read_input("12-a")
      |> Adventofcode2021.Day12.solve_a()
      |> Adventofcode2021.write_output("12-a")

    assert output == :ok
  end

  test "day 12-b sample" do
    result =
      Adventofcode2021.read_sample("12-b")
      |> Adventofcode2021.Day12.solve_b()
    assert result == 3509
  end

  test "day 12-b input" do
    output =
      Adventofcode2021.read_input("12-b")
      |> Adventofcode2021.Day12.solve_b()
      |> Adventofcode2021.write_output("12-b")

    assert output == :ok
  end

  test "day 14-b sample" do
    result =
      Adventofcode2021.read_sample("14-b")
      |> Adventofcode2021.Day14.solve_b()
    assert result == 35092188189693529
  end
end
