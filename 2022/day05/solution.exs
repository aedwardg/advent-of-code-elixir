defmodule Crates do
  def separate_instructions(data) do
    do_separate_instructions(data, {[], []})
  end

  defp do_separate_instructions([h | t] = data, {boxes, instructions}) do
    if String.match?(h, ~r/move/) do
      {Enum.reverse(boxes), data}
    else
      do_separate_instructions(t, {[h | boxes], instructions})
    end
  end

  def parse_instructions(instructions) do
    pattern = ~r/move (?<num>\d+) from (?<col_a>\d+) to (?<col_b>\d+)/

    instructions
    |> Enum.map(&Regex.named_captures(pattern, &1))
    |> Enum.map(&Map.new(&1, fn {k, v} -> {k, String.to_integer(v)} end))
  end

  def to_stacks(boxes) do
    boxes
    |> Enum.map(&format_box/1)
    |> Enum.zip()
    |> Enum.map(fn box ->
      Tuple.to_list(box)
      |> Enum.join()
      |> String.split(" ", trim: true)
    end)
    |> Enum.with_index()
    |> Map.new(fn {list, i} -> {i + 1, list} end)
  end

  defp format_box(box) do
    box
    |> Kernel.<>(" ")
    |> String.split("")
    |> Enum.chunk_every(4)
    |> Enum.reject(&(&1 == [""]))
    |> Enum.concat()
    |> Enum.reject(&String.match?(&1, ~r/^$/))
    |> Enum.chunk_every(4)
  end

  def execute(instructions, boxes, in_order \\ false)
  def execute([], boxes, _), do: boxes

  def execute([h | t], boxes, in_order) do
    if in_order do
      move_crates_in_order(t, boxes, h["num"], h["col_a"], h["col_b"])
    else
      move_crates(t, boxes, h["num"], h["col_a"], h["col_b"])
    end
  end

  defp move_crates(instructions, boxes, 0, _, _), do: execute(instructions, boxes)

  defp move_crates(instructions, boxes, num, col_a, col_b) do
    [from | rest] = boxes[col_a]
    to = boxes[col_b]
    new_boxes = %{boxes | col_a => rest, col_b => [from | to]}

    move_crates(instructions, new_boxes, num - 1, col_a, col_b)
  end

  defp move_crates_in_order(instructions, boxes, num, col_a, col_b) do
    {from, rest} = Enum.split(boxes[col_a], num)
    to = boxes[col_b]
    new_boxes = %{boxes | col_a => rest, col_b => from ++ to}

    execute(instructions, new_boxes, true)
  end
end

{boxes, moves} =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Crates.separate_instructions()

stacks = Crates.to_stacks(boxes)
instructions = Crates.parse_instructions(moves)

# PART 1
Crates.execute(instructions, stacks)
|> Enum.map(fn {_, v} -> hd(v) end)
|> IO.inspect()

# PART 2
Crates.execute(instructions, stacks, true)
|> Enum.map(fn {_, v} -> hd(v) end)
|> IO.inspect()
