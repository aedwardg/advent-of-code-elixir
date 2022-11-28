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
  for i <- 0..(length(hd(chars)) - 1), reduce: [] do
    acc ->
      chars
      |> Enum.map(&List.delete_at(&1, i))
      |> Enum.map(&List.to_string/1)
      |> Enum.group_by(& &1)
      |> Enum.find_value(fn {_k, v} ->
        if length(v) > 1, do: hd(v), else: nil
      end) || acc
  end

IO.puts("PART 2")
IO.puts(common)
