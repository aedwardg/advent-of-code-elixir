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
  |> Enum.map(fn [a, b] -> a..(a + b - 1) end)

# brute force 1
# for r <- ranges,
#     i <- r,
#     reduce: :infinity do
#   :infinity -> 
#     Seeds.find_location(i, maps)
#   acc ->
#     loc = Seeds.find_location(i, maps)
#     if loc < acc, do: loc, else: acc
# end
# |> IO.inspect()

# concurrent brute force
# for range <- ranges do
#   range
#   |> Task.async_stream(
#     fn i ->
#       Seeds.find_location(i, maps)
#     end,
#     ordered: false
#   )
#   |> Stream.map(fn {:ok, loc} -> loc end)
#   |> Enum.reduce(:infinity, fn
#     loc, :infinity -> loc
#     loc, acc -> min(loc, acc)
#   end)
# end
# |> Enum.min()
# |> IO.inspect()
