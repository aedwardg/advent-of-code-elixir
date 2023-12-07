# Part 1
hand_types =
  [[5], [4, 1], [3, 2], [3, 1, 1], [2, 2, 1], [2, 1, 1, 1], [1, 1, 1, 1, 1]]
  |> Enum.zip([
    :five_of_a_kind,
    :four_of_a_kind,
    :full_house,
    :three_of_a_kind,
    :two_pair,
    :one_pair,
    :high_card
  ])
  |> Map.new()

defmodule HandSorter do
  @cards ~w(A K Q J T 9 8 7 6 5 4 3 2)
         |> Enum.zip(14..2)
         |> Map.new()

  def compare(list_a, list_b) when list_a == list_b, do: :eq

  def compare([a | rest_a], [b | rest_b]) do
    cond do
      @cards[a] > @cards[b] -> :gt
      @cards[a] < @cards[b] -> :lt
      @cards[a] == @cards[b] -> compare(rest_a, rest_b)
    end
  end
end

hands =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split/1)
  |> Enum.map(fn [h, b] ->
    %{hand: String.split(h, "", trim: true), bet: String.to_integer(b)}
  end)
  |> Enum.map(fn h ->
    freqs = Enum.frequencies(h.hand)
    type = freqs |> Map.values() |> Enum.sort(:desc)

    h
    |> Map.merge(%{freqs: freqs, type: hand_types[type]})
  end)

sorted =
  hands
  |> Enum.group_by(& &1.type)
  |> Enum.flat_map(fn {_k, v} ->
    v
    |> Enum.sort_by(& &1.hand, {:desc, HandSorter})
  end)

for {hand, i} <- Enum.with_index(sorted),
    len = length(sorted),
    reduce: 0 do
  acc ->
    acc + hand.bet * (len - i)
end
|> IO.inspect()
