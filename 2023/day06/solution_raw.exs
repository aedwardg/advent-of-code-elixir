# part 1
records =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(fn
    "Time:" <> rest -> rest |> String.split() |> Enum.map(&String.to_integer/1)
    "Distance:" <> rest -> rest |> String.split() |> Enum.map(&String.to_integer/1)
  end)
  |> List.zip()

times =
  for {time, _dist} <- records do
    0..time
    |> Enum.reduce(%{}, fn i, acc ->
      d = i * (time - i)
      Map.put(acc, i, d)
    end)
  end

for {{_, dist}, time_map} <- Enum.zip(records, times) do
  time_map
  |> Enum.filter(&(elem(&1, 1) > dist))
  |> Enum.count()
end
|> Enum.product()
|> IO.inspect()

# part 2
defmodule BinSearch do
  def search(time, dist) do
    min = find_min(time, dist, 0, time, 0)
    max = find_max(time, dist, 0, time, 0)
    max + 1 - min
  end

  defp find_min(_, _, low, high, min) when high < low, do: min

  defp find_min(time, dist, low, high, min) do
    mid = div(low + high, 2)
    d = mid * (time - mid)

    # if d is greater than dist, try to go lower, else go higher
    if d > dist do
      find_min(time, dist, low, mid - 1, mid)
    else
      find_min(time, dist, mid + 1, high, min)
    end
  end

  defp find_max(_, _, low, high, max) when high < low, do: max

  defp find_max(time, dist, low, high, max) do
    mid = div(low + high, 2)
    d = mid * (time - mid)

    # if d is greater than dist, try to go higher, else go lower
    if d > dist do
      find_max(time, dist, mid + 1, high, mid)
    else
      find_max(time, dist, low, mid - 1, max)
    end
  end
end

[time, dist] =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(fn
    "Time:" <> rest ->
      rest |> String.split() |> Enum.reduce("", &(&2 <> &1)) |> String.to_integer()

    "Distance:" <> rest ->
      rest |> String.split() |> Enum.reduce("", &(&2 <> &1)) |> String.to_integer()
  end)

BinSearch.search(time, dist)
|> IO.inspect()
