defmodule FreqChecker do
  def find_duplicate(inputs) do
    do_find_duplicate(inputs)
  end

  defp do_find_duplicate(inputs, freq \\ 0, set \\ MapSet.new([0])) do
    do_find_duplicate(inputs, inputs, freq, set)
  end

  defp do_find_duplicate([], orig, freq, set), do: do_find_duplicate(orig, freq, set)

  defp do_find_duplicate([h | t], orig, freq, set) do
    new_freq = freq + String.to_integer(h)

    if MapSet.member?(set, new_freq) do
      new_freq
    else
      do_find_duplicate(t, orig, new_freq, MapSet.put(set, new_freq))
    end
  end
end

inputs =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)

# PART 1
IO.puts("PART 1")

inputs
|> Enum.reduce(0, fn input, freq ->
  freq + String.to_integer(input)
end)
|> IO.puts()

# PART 2
IO.puts("PART 2")
IO.puts(FreqChecker.find_duplicate(inputs))
