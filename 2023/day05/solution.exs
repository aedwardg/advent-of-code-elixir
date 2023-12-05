defmodule Seeds do
  def parse(path) do
    ["seeds: " <> seeds | maps] =
      File.read!(path)
      |> String.split("\n\n", trim: true)

    seeds =
      seeds
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    maps = Enum.map(maps, &parse_map/1)
    {seeds, maps}
  end

  defp parse_map(map_str) do
    [_ | lines] =
      map_str
      |> String.split("\n", trim: true)

    for line <- lines,
        nums = String.split(line),
        [dest, source, range] = Enum.map(nums, &String.to_integer/1) do
      %{dest: dest, source: source, range: range}
    end
  end

  def find_location(num, []), do: num

  def find_location(num, [rules | rest]) do
    rules
    |> Enum.filter(fn %{source: s, range: r} ->
      num >= s && num <= s + r - 1
    end)
    |> case do
      [] -> num
      [%{source: s, dest: d}] -> d + (num - s)
    end
    |> find_location(rest)
  end

  # highly influenced by https://github.com/nherzing/aoc23/blob/master/d05.livemd
  # since I was was struggling to get the Elixir implementation right for 
  # the range splitting
  def split_ranges({start, stop}, maps) when stop < start, do: []
  def split_ranges(range, []), do: [range]

  def split_ranges({start, stop}, [rules | rest]) do
    rules
    |> Enum.find(fn %{source: src, range: sz} ->
      (start >= src && start <= src + sz - 1) || (stop >= src && stop <= src + sz - 1)
    end)
    |> case do
      nil ->
        [{start, stop}]

      %{dest: dest, source: src, range: sz} ->
        overlap_st = max(start, src)
        overlap_end = min(stop, src + sz - 1)

        mapped = [{dest + (overlap_st - src), dest + (overlap_end - src)}]
        mapped_left = split_ranges({start, overlap_st - 1}, [rules])
        mapped_right = split_ranges({overlap_end + 1, stop}, [rules])
        Enum.concat([mapped_left, mapped, mapped_right])
    end
    |> Enum.flat_map(&split_ranges(&1, rest))
  end
end

{seeds, maps} = Seeds.parse("./input.txt")
# part 1
seeds
|> Enum.map(&Seeds.find_location(&1, maps))
|> Enum.min()
|> IO.inspect()

# part 2
ranges =
  seeds
  |> Enum.chunk_every(2)
  |> Enum.map(fn [a, b] -> {a, a + b - 1} end)
  |> Enum.map(&Seeds.split_ranges(&1, maps))
  |> Enum.map(fn locs -> locs |> Enum.map(&elem(&1, 0)) |> Enum.min() end)
  |> Enum.min()
  |> IO.inspect()
