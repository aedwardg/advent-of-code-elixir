lines =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)

games =
  lines
  |> Enum.map(fn line ->
    line
    |> String.split(": ")
    |> then(fn [game, cubes] ->
      id = game |> String.split(" ") |> List.last() |> String.to_integer()
      draws = cubes |> String.split("; ", trim: true)
      {id, draws}
    end)
  end)

defmodule Cube do
  @constraints %{"red" => 12, "green" => 13, "blue" => 14}
  @pattern ~r/(\d+) (red|green|blue)/

  def sum([], count), do: count

  def sum([game | rest], count) do
    {id, draws} = game

    count = if valid?(draws), do: count + id, else: count
    sum(rest, count)
  end

  defp valid?(draws) do
    draws
    |> Enum.flat_map(fn draw ->
      @pattern
      |> Regex.scan(draw, capture: :all_but_first)
      |> Enum.map(fn [num, color] ->
        {color, String.to_integer(num)}
      end)
    end)
    |> Enum.all?(fn {color, amt} -> amt <= @constraints[color] end)
  end

  def sum_of_powers(games) do
    games
    |> Enum.map(&power/1)
    |> Enum.sum()
  end

  def power({_id, draws}) do
    for draw <- draws,
        [num, color] <- Regex.scan(@pattern, draw, capture: :all_but_first),
        reduce: %{} do
      acc ->
        amt = String.to_integer(num)

        if !acc[color] || acc[color] < amt do
          Map.put(acc, color, amt)
        else
          acc
        end
    end
    |> Map.values()
    |> Enum.product()
  end
end

Cube.sum(games, 0) |> IO.inspect()
Cube.sum_of_powers(games) |> IO.inspect()
