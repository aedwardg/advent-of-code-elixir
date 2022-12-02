points = %{"rock" => 1, "paper" => 2, "scissors" => 3, "loss" => 0, "draw" => 3, "win" => 6}

rules = %{
  "A X" => {"rock", "draw"},
  "A Y" => {"paper", "win"},
  "A Z" => {"scissors", "loss"},
  "B X" => {"rock", "loss"},
  "B Y" => {"paper", "draw"},
  "B Z" => {"scissors", "win"},
  "C X" => {"rock", "win"},
  "C Y" => {"paper", "loss"},
  "C Z" => {"scissors", "draw"}
}

new_rules = %{
  "A X" => {"scissors", "loss"},
  "A Y" => {"rock", "draw"},
  "A Z" => {"paper", "win"},
  "B X" => {"rock", "loss"},
  "B Y" => {"paper", "draw"},
  "B Z" => {"scissors", "win"},
  "C X" => {"paper", "loss"},
  "C Y" => {"scissors", "draw"},
  "C Z" => {"rock", "win"}
}

get_score = fn plays, rules ->
  plays
  |> Enum.reduce(0, fn play, acc ->
    {move, result} = rules[play]
    acc + points[move] + points[result]
  end)
end

plays =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)

IO.puts(get_score.(plays, rules))
IO.puts(get_score.(plays, new_rules))
