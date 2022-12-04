pattern = ~r/(?<start1>\d+)-(?<end1>\d+),(?<start2>\d+)-(?<end2>\d+)/

data =
  File.stream!("./input.txt")
  |> Stream.reject(&(&1 == "\n"))
  |> Stream.map(&Regex.named_captures(pattern, &1))
  |> Stream.map(&Map.new(&1, fn {k, v} -> {k, String.to_integer(v)} end))
  |> Stream.map(fn m ->
    {MapSet.new(m["start1"]..m["end1"]), MapSet.new(m["start2"]..m["end2"])}
  end)

_part_one =
  data
  |> Enum.reduce(0, fn {a1, a2}, acc ->
    if MapSet.subset?(a1, a2) or MapSet.subset?(a2, a1), do: acc + 1, else: acc
  end)
  |> IO.inspect()

_part_two =
  data
  |> Enum.reduce(0, fn {a1, a2}, acc ->
    if MapSet.size(MapSet.intersection(a1, a2)) > 0, do: acc + 1, else: acc
  end)
  |> IO.inspect()
