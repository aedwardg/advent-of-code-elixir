defmodule Scratchers do
  def parse(path) do
    File.read!(path)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [info, nums] = String.split(line, ": ", trim: true)
      id = info |> String.split(" ") |> List.last() |> String.to_integer()
      [w, c] = String.split(nums, "| ", trim: true)

      winning =
        w |> String.split(~r/\s/, trim: true) |> Enum.map(&String.to_integer/1) |> MapSet.new()

      current =
        c |> String.split(~r/\s/, trim: true) |> Enum.map(&String.to_integer/1) |> MapSet.new()

      %{id: id, winning: winning, current: current}
    end)
  end

  def calculate_score(card) do
    %{winning: winning, current: current} = card
    matches = MapSet.intersection(winning, current)

    matches
    |> MapSet.to_list()
    |> Enum.reduce(0, fn _n, acc ->
      case acc do
        0 -> 1
        _ -> acc * 2
      end
    end)
  end

  def total_winners(cards) do
    copy_count =
      Enum.reduce(1..length(cards), %{}, fn i, acc ->
        Map.put(acc, i, 1)
      end)

    for %{id: id, winning: ws, current: cs} <- cards,
        num_matches = MapSet.intersection(ws, cs) |> MapSet.to_list() |> Enum.count(),
        max = length(cards),
        reduce: copy_count do
      acc ->
        case num_matches do
          0 ->
            acc

          _ ->
            (id + 1)..(id + num_matches)
            |> Enum.reduce(acc, fn i, inner ->
              if i <= max do
                Map.update!(inner, i, fn curr -> curr + inner[id] end)
              end
            end)
        end
    end
    |> Enum.reduce(0, &(elem(&1, 1) + &2))
  end
end

cards = Scratchers.parse("./input.txt")

# part 1
cards
|> Enum.map(&Scratchers.calculate_score/1)
|> Enum.sum()
|> IO.inspect()

# part 2
cards
|> Scratchers.total_winners()
|> IO.inspect()
