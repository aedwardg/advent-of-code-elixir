defmodule HistoricalLists do
  def parse(path) do
    File.stream!(path)
    |> Stream.reject(&(&1 == "\n"))
    |> Stream.map(&String.split(&1, ~r/[[:space:]]+/, trim: true))
    |> Enum.reduce([[], []], fn [a, b], [l, r] ->
      [[String.to_integer(a) | l], [String.to_integer(b) | r]]
    end)
    |> Enum.map(&Enum.sort/1)
  end

  def total_distance([lefts, rights]) do
    lefts
    |> Enum.zip(rights)
    |> Enum.reduce(0, &(&2 + abs(elem(&1, 0) - elem(&1, 1))))
  end

  def similarity_score([lefts, rights]) do
    freqs = Enum.frequencies(rights)

    lefts
    |> Enum.reduce(0, fn num, acc ->
      acc + num * (freqs[num] || 0)
    end)
  end
end

input = HistoricalLists.parse("./input.txt")
HistoricalLists.total_distance(input) |> IO.inspect()
HistoricalLists.similarity_score(input) |> IO.inspect()
