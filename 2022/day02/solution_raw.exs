plays =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(fn s ->
    String.split(s, " ") |> List.to_tuple()
  end)

points = %{"X" => 1, "Y" => 2, "Z" => 3, "loss" => 0, "draw" => 3, "win" => 6}

rules = %{
  {"A", "X"} => "draw",
  {"A", "Y"} => "win",
  {"A", "Z"} => "loss",
  {"B", "X"} => "loss",
  {"B", "Y"} => "draw",
  {"B", "Z"} => "win",
  {"C", "X"} => "win",
  {"C", "Y"} => "loss",
  {"C", "Z"} => "draw"
}

plays
|> Enum.reduce(0, fn {i, j} = play, acc ->
  IO.inspect(play)
  result = rules[play]
  acc + points[j] + points[result]
end)
|> IO.inspect()

new_rules = %{
  {"A", "X"} => {"Z", "loss"},
  {"A", "Y"} => {"X", "draw"},
  {"A", "Z"} => {"Y", "win"},
  {"B", "X"} => {"X", "loss"},
  {"B", "Y"} => {"Y", "draw"},
  {"B", "Z"} => {"Z", "win"},
  {"C", "X"} => {"Y", "loss"},
  {"C", "Y"} => {"Z", "draw"},
  {"C", "Z"} => {"X", "win"}
}

plays
|> Enum.reduce(0, fn {i, j} = play, acc ->
  {result, move}= new_rules[play]
  acc + points[move] + points[result]
end)
|> IO.inspect()
