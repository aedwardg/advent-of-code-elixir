defmodule Scratchers do
  def parse(path) do
    File.read!(path)
    |> String.split("\n", trim: true)
    |> Enum.with_index(1)
    |> Enum.map(fn {line, id} ->
      [winning, current] =
        line
        |> String.split(": ", trim: true)
        |> Enum.at(1)
        |> String.split("| ", trim: true)
        |> Enum.map(&MapSet.new(String.split(&1)))

      %{id: id, winning: winning, current: current}
    end)
  end

  def calculate_score(card) do
    %{winning: ws, current: cs} = card

    ws
    |> MapSet.intersection(cs)
    |> Enum.reduce(0, fn
      _n, 0 -> 1
      _n, acc -> acc * 2
    end)
  end

  def total_winners(cards) do
    copy_count = Enum.reduce(1..length(cards), %{}, &Map.put(&2, &1, 1))

    for %{id: id, winning: ws, current: cs} <- cards,
        num_matches = Enum.count(MapSet.intersection(ws, cs)),
        num_matches > 0,
        reduce: copy_count do
      counts ->
        (id + 1)..(id + num_matches)
        |> Enum.reduce(counts, fn i, acc ->
          Map.update!(acc, i, &(&1 + acc[id]))
        end)
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
