defmodule Parser do
  def parse(path) do
    lines =
      File.read!(path)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    width = lines |> List.first() |> length()
    height = length(lines)

    map =
      for {line, y} <- Enum.with_index(lines),
          {char, x} <- Enum.with_index(line),
          into: %{} do
        {{x, y}, char}
      end

    {width, height, map}
  end
end

defmodule Ski do
  def start({x, y}, {right, down} = slope, map, bounds) do
    traverse({x + right, y + down}, slope, map, bounds, 0)
  end

  def traverse({_, y}, _, _, {_, height}, count) when y > height, do: count

  def traverse(start, slope, map, bounds, count) do
    {x, y} = start
    {right, down} = slope
    {width, _} = bounds

    count = if map[start] == "#", do: count + 1, else: count

    new_x = rem(x + right, width)
    new_y = y + down

    traverse({new_x, new_y}, slope, map, bounds, count)
  end
end

{width, height, map} = Parser.parse("./input.txt")

# part 1
Ski.start({0, 0}, {3, 1}, map, {width, height}) |> IO.inspect()

# part 2 
slopes = [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

slopes
|> Enum.map(&Ski.start({0, 0}, &1, map, {width, height}))
|> Enum.reduce(&*/2)
|> IO.inspect()
