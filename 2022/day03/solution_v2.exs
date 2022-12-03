defmodule Priority do
  def from_duplicate(rucksack) do
    rucksack
    |> Enum.split(div(length(rucksack), 2))
    |> Tuple.to_list()
    |> common_item_priority()
  end

  def from_group(group), do: group |> common_item_priority()

  defp common_item_priority(collection) do
    collection
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> Enum.to_list()
    |> hd()
    |> priority()
  end

  defp priority(char) do
    bin = hd(String.to_charlist(char))

    if bin > ?Z, do: bin - 96, else: bin - 38
  end
end

data =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))

# PART 1
data
|> Enum.reduce(0, &Kernel.+(Priority.from_duplicate(&1), &2))
|> IO.inspect()

# PART 2
data
|> Enum.chunk_every(3)
|> Enum.reduce(0, &Kernel.+(Priority.from_group(&1), &2))
|> IO.inspect()
