defmodule Clock do
  def tick(instructions, cycle \\ 1, x \\ 1, map \\ %{})
  def tick([], _, _, map), do: map

  def tick(["noop" | t], cycle, x, map) do
    new_map = map |> Map.put(cycle, x)
    tick(t, cycle + 1, x, new_map)
  end

  def tick(["addx " <> v | t], cycle, x, map) do
    val = String.to_integer(v)

    new_map =
      map
      |> Map.put(cycle, x)
      |> Map.put(cycle + 1, x)

    tick(t, cycle + 2, x + val, new_map)
  end

  def signal_strengths(map, cycles) do
    cycles
    |> Enum.map(&(&1 * map[&1]))
    |> Enum.sum()
  end

  def map_sprite(map) do
    row_1 = 1..40 |> Enum.reduce("", &mark_pixel(&1, &2, map))
    row_2 = 41..80 |> Enum.reduce("", &mark_pixel(&1, &2, map))
    row_3 = 81..120 |> Enum.reduce("", &mark_pixel(&1, &2, map))
    row_4 = 121..160 |> Enum.reduce("", &mark_pixel(&1, &2, map))
    row_5 = 161..200 |> Enum.reduce("", &mark_pixel(&1, &2, map))
    row_6 = 201..240 |> Enum.reduce("", &mark_pixel(&1, &2, map))

    [row_1, row_2, row_3, row_4, row_5, row_6]
  end

  def mark_pixel(cycle, str, map) do
    pos = rem(cycle, 40)
    pos = if pos == 0, do: 40, else: pos

    if pos in map[cycle]..(map[cycle] + 2) do
      str <> "#"
    else
      str <> "."
    end
  end
end

interesting = [20, 60, 100, 140, 180, 220]

input =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)

tick_map = input |> Clock.tick()

# PART 1
tick_map
|> Clock.signal_strengths(interesting)
|> IO.inspect()

# PART 2
tick_map
|> Clock.map_sprite()
|> IO.inspect()
