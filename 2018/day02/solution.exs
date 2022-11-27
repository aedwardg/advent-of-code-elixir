chars =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.graphemes/1)

# PART 1
checksum =
  chars
  |> Enum.map(&Enum.frequencies/1)
  |> Enum.reduce([0, 0], fn freq, [twos, threes] ->
    vals = Map.values(freq)

    twos = if Enum.any?(vals, fn x -> x == 2 end), do: twos + 1, else: twos
    threes = if Enum.any?(vals, fn x -> x == 3 end), do: threes + 1, else: threes

    [twos, threes]
  end)
  |> Enum.product()

IO.puts("PART 1")
IO.puts(checksum)

# PART 2 
common =
  for i <- 0..(length(List.first(chars)) - 1), into: [] do
    chars
    |> Enum.map(&List.delete_at(&1, i))
    |> Enum.map(&List.to_string/1)
    |> Enum.group_by(& &1)
    |> Map.values()
    |> Enum.find(fn x -> length(x) > 1 end)
  end
  |> Enum.reject(&is_nil/1)
  |> List.flatten()
  |> Enum.uniq()

IO.puts("PART 2")
IO.puts(common)
