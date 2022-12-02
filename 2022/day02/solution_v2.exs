defmodule RPS do
  def get_score_one("A X", score), do: 4 + score
  def get_score_one("A Y", score), do: 8 + score
  def get_score_one("A Z", score), do: 3 + score
  def get_score_one("B X", score), do: 1 + score
  def get_score_one("B Y", score), do: 5 + score
  def get_score_one("B Z", score), do: 9 + score
  def get_score_one("C X", score), do: 7 + score
  def get_score_one("C Y", score), do: 2 + score
  def get_score_one("C Z", score), do: 6 + score

  def get_score_two("A X", score), do: 3 + score
  def get_score_two("A Y", score), do: 4 + score
  def get_score_two("A Z", score), do: 8 + score
  def get_score_two("B X", score), do: 1 + score
  def get_score_two("B Y", score), do: 5 + score
  def get_score_two("B Z", score), do: 9 + score
  def get_score_two("C X", score), do: 2 + score
  def get_score_two("C Y", score), do: 6 + score
  def get_score_two("C Z", score), do: 7 + score
end

plays =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)

IO.puts(Enum.reduce(plays, 0, &RPS.get_score_one(&1, &2)))
IO.puts(Enum.reduce(plays, 0, &RPS.get_score_two(&1, &2)))
