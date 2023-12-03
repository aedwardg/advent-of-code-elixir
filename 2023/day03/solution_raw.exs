defmodule Gondola do
  def parse(path) do
    lines =
      File.read!(path)
      |> String.split("\n", trim: true)

    max_y = length(lines) - 1
    max_x = String.length(hd(lines)) - 1

    schematic =
      for {line, y} <- Enum.with_index(lines),
          nums = List.flatten(Regex.scan(~r/\d+/, line)),
          locs = List.flatten(Regex.scan(~r/\d+/, line, return: :index)) do
        points =
          locs
          |> Enum.map(fn {start_x, len} ->
            end_x = start_x + (len - 1)

            start_x..end_x
            |> Enum.map(&{&1, y})
          end)

        neighbors =
          locs
          |> Enum.map(&build_neighbors(&1, y, max_x, max_y))

        nums
        |> Enum.map(&String.to_integer/1)
        |> Enum.zip(neighbors)
        |> Enum.zip_reduce(points, [], fn {num, ns}, point, acc -> [{num, ns, point} | acc] end)
      end
      |> List.flatten()

    symbols =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        symbols = List.flatten(Regex.scan(~r/[^.\d]/, line, return: :index))

        if symbols == [] do
          acc
        else
          record_symbols(symbols, y, acc)
        end
      end)

    stars =
      for {line, y} <- Enum.with_index(lines),
          {char, x} <- Enum.with_index(String.graphemes(line)),
          reduce: %{} do
        acc ->
          adjacent = [
            {x - 1, y},
            {x - 1, y - 1},
            {x - 1, y + 1},
            {x, y - 1},
            {x, y + 1},
            {x + 1, y},
            {x + 1, y - 1},
            {x + 1, y + 1}
          ]

          if char == "*" do
            Map.put(acc, {x, y}, adjacent)
          else
            acc
          end
      end

    {schematic, symbols, stars}
  end

  defp build_neighbors({start_x, len}, y, max_x, max_y) do
    end_x = start_x + (len - 1)
    points = Enum.to_list(start_x..end_x)

    for point <- points do
      positions =
        point
        |> find_vert_neighbors(y, max_y)

      cond do
        start_x == end_x ->
          positions ++
            find_left_neighbors(point, y, max_y) ++ find_right_neighbors(point, y, max_x, max_y)

        point == start_x ->
          find_left_neighbors(point, y, max_y) ++ positions

        point == end_x ->
          find_right_neighbors(point, y, max_x, max_y) ++ positions

        true ->
          positions
      end
    end
    |> List.flatten()
  end

  defp find_vert_neighbors(x, y, max_y) do
    case y do
      0 -> [{x, y + 1}]
      ^max_y -> [{x, y - 1}]
      _ -> [{x, y + 1}, {x, y - 1}]
    end
  end

  defp find_left_neighbors(x, y, max_y) do
    cond do
      x == 0 -> []
      y == 0 -> [{x - 1, y}, {x - 1, y + 1}]
      y == max_y -> [{x - 1, y}, {x - 1, y - 1}]
      true -> [{x - 1, y}, {x - 1, y - 1}, {x - 1, y + 1}]
    end
  end

  defp find_right_neighbors(x, y, max_x, max_y) do
    cond do
      x == max_x -> []
      y == 0 -> [{x + 1, y}, {x + 1, y + 1}]
      y == max_y -> [{x + 1, y}, {x + 1, y - 1}]
      true -> [{x + 1, y}, {x + 1, y - 1}, {x + 1, y + 1}]
    end
  end

  defp record_symbols([], _y, map), do: map

  defp record_symbols([{x, _} | t], y, map) do
    updated = Map.put(map, {x, y}, true)
    record_symbols(t, y, updated)
  end
end

{schematic, symbols, stars} = Gondola.parse("./input.txt")

# part 1
schematic
|> Enum.reduce(0, fn {num, ns, _loc}, sum ->
  if Enum.any?(ns, &Map.get(symbols, &1)) do
    sum + num
  else
    sum
  end
end)
|> IO.inspect()

# part 2
for {_k, v} = star <- stars,
    {num, _ns, locs} <- schematic,
    loc <- locs,
    reduce: %{} do
  acc ->
    if loc in v do
      Map.update(acc, star, MapSet.new([num]), fn set -> MapSet.put(set, num) end)

    else
      acc
    end
end
|> Map.values()
|> Enum.map(&MapSet.to_list/1)
|> Enum.filter(&(length(&1) == 2))
|> Enum.map(&Enum.product/1)
|> Enum.sum()
|> IO.inspect()
