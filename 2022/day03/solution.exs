defmodule Priority do
  def from_char(char) do
    bin = hd(String.to_charlist(char))

    if bin > 90, do: bin - 96, else: bin - 38
  end
end

data =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))

part_one =
  data
  |> Enum.reduce(0, fn s, acc ->
    len = length(s)
    half = div(len - 1, 2)
    c1 = Enum.slice(s, 0..half)
    c2 = Enum.slice(s, (half + 1)..-1)

    wrong = Enum.find(c1, fn char -> char in c2 end)
    Priority.from_char(wrong) + acc
  end)

IO.inspect(part_one)

chunks =
  data
  |> Enum.chunk_every(3)

sets =
  for chunk <- chunks do
    chunk |> Enum.map(&MapSet.new/1)
  end

part_two =
  sets
  |> Enum.reduce(0, fn [a, b, c], acc ->
    badge = Enum.find(a, fn char -> char in b && char in c end)
    Priority.from_char(badge) + acc
  end)

IO.inspect(part_two)
