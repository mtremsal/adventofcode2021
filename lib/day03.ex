defmodule Adventofcode2021.Day03 do
  require Logger

  # Part a
  def solve_a(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")

    file
    |> String.split("\n")
    # |> Enum.map(&String.to_charlist/1)
    |> most_common_value_in_array("")
    |> then(&{&1, complement_of_string(&1, "")})
    |> then(fn {a, b} -> {Integer.parse(a, 2) |> elem(0), Integer.parse(b, 2) |> elem(0)} end)
  end

  def complement_of_string("", result) do
    result
  end

  def complement_of_string(string, result) do
    <<head::binary-size(1)>> <> tail = string

    flipped_letter =
      if head == "0" do
        "1"
      else
        "0"
      end

    complement_of_string(tail, result <> flipped_letter)
  end

  def most_common_value_in_array(array_of_strings, string_of_most_common_values) do
    # Ugly base case
    [head | _tail] = array_of_strings
    # Recursion
    if head == "" do
      string_of_most_common_values
    else
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

  # Part b
  def solve_b(file) do
    Logger.debug("Solving problem a in #{__MODULE__}")

    string_array_with_index =
      file
      |> String.split("\n")
      |> Enum.with_index()

    o2 =
      string_array_with_index
      |> Enum.at(string_array_with_index |> filter_for_o2())
      |> elem(0)

    co2 =
      string_array_with_index
      |> Enum.at(string_array_with_index |> filter_for_co2())
      |> elem(0)

    {Integer.parse(o2, 2) |> elem(0), Integer.parse(co2, 2) |> elem(0)}
  end

  def filter_for_o2(string_array_with_index) do
    most_common_digit_for_o2 =
      string_array_with_index
      |> Enum.map(&(&1 |> elem(0)))
      |> Enum.map(fn <<head::binary-size(1)>> <> _tail -> head end)
      |> Enum.count(&(&1 == "1"))
      |> then(&(&1 >= length(string_array_with_index) / 2))
      |> bool_to_digit()

    filtered_string_array_with_index =
      string_array_with_index
      |> filter_for_digit(most_common_digit_for_o2)
      |> drop_first_digit()

    if length(filtered_string_array_with_index) == 1 do
      filtered_string_array_with_index
      |> then(fn [head | _tail] -> head end)
      |> elem(1)
    else
      filter_for_o2(filtered_string_array_with_index)
    end
  end

  def filter_for_co2(string_array_with_index) do
    least_common_digit_for_co2 =
      string_array_with_index
      |> Enum.map(&(&1 |> elem(0)))
      |> Enum.map(fn <<head::binary-size(1)>> <> _tail -> head end)
      |> Enum.count(&(&1 == "1"))
      |> then(&(&1 < length(string_array_with_index) / 2))
      |> bool_to_digit()

    filtered_string_array_with_index =
      string_array_with_index
      |> filter_for_digit(least_common_digit_for_co2)
      |> drop_first_digit()

    if length(filtered_string_array_with_index) == 1 do
      filtered_string_array_with_index
      |> then(fn [head | _tail] -> head end)
      |> elem(1)
    else
      filter_for_co2(filtered_string_array_with_index)
    end
  end

  def filter_for_digit(string_array_with_index, digit) do
    string_array_with_index
    |> Enum.filter(fn x ->
      {string, _key} = x
      <<head::binary-size(1)>> <> _tail = string
      head == digit
    end)
  end

  def drop_first_digit(string_array_with_index) do
    string_array_with_index
    |> Enum.map(fn {<<_head::binary-size(1)>> <> tail, value} ->
      {tail, value}
    end)
  end

  def bool_to_digit(bool) do
    if bool do
      "1"
    else
      "0"
    end
  end
end
