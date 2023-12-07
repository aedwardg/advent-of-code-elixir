# Part 2
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
  @cards ~w(A K Q T 9 8 7 6 5 4 3 2 J)
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

cards =
  ~w(A K Q T 9 8 7 6 5 4 3 2 J)
  |> Enum.zip(14..2)
  |> Map.new()

hands =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split/1)
  |> Enum.map(fn [h, b] ->
    %{hand: String.split(h, "", trim: true), bet: String.to_integer(b)}
  end)
  |> Enum.map(fn h ->
    freqs = Enum.frequencies(h.hand)

    freqs =
      cond do
        freqs["J"] && freqs["J"] == 5 ->
          %{"A" => 5}

        !freqs["J"] ->
          freqs

        true ->
          sorted_freqs =
            freqs
            |> Enum.sort_by(&{elem(&1, 1), cards[elem(&1, 0)]}, :desc)

          highest =
            sorted_freqs
            |> hd()
            |> case do
              {"J", _} -> sorted_freqs |> Enum.at(1) |> elem(0)
              _ -> sorted_freqs |> hd() |> elem(0)
            end

          sorted_freqs
          |> Map.new()
          |> Map.update!(highest, &(&1 + freqs["J"]))
          |> Map.drop(["J"])
      end

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
