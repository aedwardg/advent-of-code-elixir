defmodule Calibration do
  @digits ~r/[[:digit:]]/
  @all_digits ~r/(?=([[:digit:]]|one|two|three|four|five|six|seven|eight|nine))/

  @word_to_num %{
    "1" => "1",
    "2" => "2",
    "3" => "3",
    "4" => "4",
    "5" => "5",
    "6" => "6",
    "7" => "7",
    "8" => "8",
    "9" => "9",
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  def sum(path, type \\ :digits) do
    File.stream!(path)
    |> Stream.reject(&(&1 == "\n"))
    |> Stream.map(&parse_from_regex(&1, type))
    |> Stream.map(fn list ->
      number = List.first(list) <> List.last(list)
      String.to_integer(number)
    end)
    |> Enum.to_list()
    |> Enum.sum()
  end

  def parse_from_regex(line, type) do
    {regex, match_idx} =
      case type do
        :all -> {@all_digits, 1}
        _ -> {@digits, 0}
      end

      regex
      |> Regex.scan(line)
      |> Enum.map(fn matches ->
        match = Enum.at(matches, match_idx)
        Map.get(@word_to_num, match)
      end)
  end
end

Calibration.sum("./input.txt") |> IO.inspect()
Calibration.sum("./input.txt", :all) |> IO.inspect()
