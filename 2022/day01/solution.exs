inputs =
  File.read!("./input.txt")
  |> String.split("\n\n", trim: true)
  |> Enum.map(fn s -> String.split(s, "\n", trim: true) end)

elves =
  for elf <- inputs do
    elf
    |> Enum.map(fn item -> String.to_integer(item) end)
  end

max_elf =
  elves
  |> Enum.map(&Enum.sum/1)
  |> Enum.max()
  |> IO.inspect()

top_three =
  elves
  |> Enum.map(&Enum.sum/1)
  |> Enum.sort(:desc)
  |> Enum.take(3)
  |> Enum.sum()
  |> IO.inspect()
