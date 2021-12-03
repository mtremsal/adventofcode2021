defmodule Adventofcode2021.Day03 do
  require Logger

  def solve_a(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")

    file
    |> String.split("\n")
    # |> Enum.map(&String.to_charlist/1)
    |> most_common_value_in_array("")
    |> then(&({&1, complement_of_string(&1, "")}))
    |> then(fn {a, b} -> {Integer.parse(a, 2) |> elem(0), Integer.parse(b, 2) |> elem(0)} end)
  end

  def complement_of_string("", result) do result end

  def complement_of_string(string, result) do
    <<head :: binary-size(1)>> <> tail = string
    flipped_letter = if head == "0" do "1" else "0" end
    complement_of_string(tail, result <> flipped_letter)
  end

  def most_common_value_in_array(array_of_strings, string_of_most_common_values) do
    # Ugly base case
    [head | _tail] = array_of_strings
    if head == "" do
      string_of_most_common_values
    else # Recursion
      most_common_value =
        array_of_strings
        # Fails on arrays of empty strings?
        |> Enum.map(&String.split_at(&1, 1))
        |> Enum.map(fn {value, _array} -> value end)
        |> most_common_value_in_array_of_single_strings()

      remaining_array_of_strings =
        array_of_strings
        |> Enum.map(&String.split_at(&1, 1))
        |> Enum.map(fn {_value, array} -> array end)

      most_common_value_in_array(
        remaining_array_of_strings,
        string_of_most_common_values <> most_common_value
      )
    end
  end

  def most_common_value_in_array_of_single_strings(array_of_strings) do
    array_of_strings
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
    |> then(fn sum -> sum > length(array_of_strings) / 2 end)
    |> then(fn bool ->
      if bool do
        "1"
      else
        "0"
      end
    end)
  end

  def string_to_decimal(string) do

  end
end
