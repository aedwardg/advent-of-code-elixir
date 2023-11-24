input =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer(&1))

defmodule PartOne do
  def find([first | rest], nums) do
    if Enum.member?(nums, 2020 - first) do
      first * (2020 - first)
    else
      find(rest, nums)
    end
  end
end

PartOne.find(input, input) |> IO.inspect()

defmodule PartTwo do
  def find(input) do
    for x <- input, y <- input, z <- input, x + y + z == 2020, reduce: 0 do
      _acc -> x * y * z
    end
  end
end

PartTwo.find(input) |> IO.inspect()
