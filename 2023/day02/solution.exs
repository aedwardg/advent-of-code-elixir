defmodule Cube do
  @constraints %{"red" => 12, "green" => 13, "blue" => 14}
  @pattern ~r/(\d+) (red|green|blue)/

  def parse(path) do
    lines =
      File.read!(path)
      |> String.split("\n", trim: true)

    for line <- lines, [game, cubes] = String.split(line, ": ") do
      id = game |> String.split(" ") |> List.last() |> String.to_integer()
      draws = cubes |> String.split("; ", trim: true)
      {id, draws}
    end
  end

  def sum([], count), do: count

  def sum([game | rest], count) do
    {id, draws} = game
    count = if valid?(draws), do: count + id, else: count

    sum(rest, count)
  end

  def sum_of_powers(games) do
    games
    |> Enum.map(&power/1)
    |> Enum.sum()
  end

  defp valid?(draws) do
    draws
    |> max_values()
    |> Enum.all?(fn {color, amt} -> amt <= @constraints[color] end)
  end

  defp power({_id, draws}) do
    draws
    |> max_values()
    |> Map.values()
    |> Enum.product()
  end

  defp max_values(draws) do
    for draw <- draws,
        [num, color] <- Regex.scan(@pattern, draw, capture: :all_but_first),
        amt = String.to_integer(num),
        reduce: %{} do
      acc ->
        if !acc[color] || acc[color] < amt do
          Map.put(acc, color, amt)
        else
          acc
        end
    end
  end
end

games = Cube.parse("./input.txt")
Cube.sum(games, 0) |> IO.inspect()
Cube.sum_of_powers(games) |> IO.inspect()
