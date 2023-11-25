defmodule Parser do
  def parse(path) do
    File.read!(path)
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_data/1)
  end

  defp extract_data(line) do
    ~r/(?<lbound>\d{1,2})-(?<ubound>\d{1,2}) (?<char>[[:alpha:]]): (?<pass>[[:alpha:]]+)/
    |> Regex.named_captures(line)
    |> clean_data()
  end

  defp clean_data(data) do
    %{"lbound" => min, "ubound" => max} = data
    min = String.to_integer(min)
    max = String.to_integer(max)
    %{data | "lbound" => min, "ubound" => max}
  end
end

defmodule PartOne do
  def count_valid(passwords) do
    do_count(passwords, 0)
  end

  defp do_count([], count), do: count

  defp do_count([first | rest], count) do
    %{"char" => char, "lbound" => min, "ubound" => max, "pass" => pass} = first

    freq =
      pass
      |> String.graphemes()
      |> Enum.count(&(&1 == char))

    if freq >= min && freq <= max do
      do_count(rest, count + 1)
    else
      do_count(rest, count)
    end
  end
end

defmodule PartTwo do
  def count_valid(input) do
    Enum.reduce(input, 0, fn m, acc ->
      if is_valid?(m), do: acc + 1, else: acc
    end)
  end

  defp is_valid?(pass_map) do
    %{"char" => char, "lbound" => pos1, "ubound" => pos2, "pass" => pass} = pass_map
    v1 = char == String.at(pass, pos1 - 1)
    v2 = char == String.at(pass, pos2 - 1)
    v1 != v2
  end
end

input = Parser.parse("input.txt")
PartOne.count_valid(input) |> IO.inspect()
PartTwo.count_valid(input) |> IO.inspect()
