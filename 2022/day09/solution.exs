defmodule Rope do
  def exec(instructions) do
    instructions
    |> Enum.reduce({{0, 0}, %{pos: {0, 0}, vis: MapSet.new([{0, 0}])}}, fn line, {head, tail} ->
      move(line, head, tail)
    end)
  end

  def exec_2(instructions) do
    tail = %{pos: {0, 0}, vis: MapSet.new([{0, 0}])}
    long_tail = 1..9 |> Enum.map(fn _ -> tail end)

    instructions
    |> Enum.reduce({{0, 0}, long_tail}, fn line, {head, long_tail} ->
      move_2(line, head, long_tail)
    end)
  end

  defp move({_, 0}, head, tail), do: {head, tail}

  defp move({dir, steps}, head, tail) do
    new_head = move_head(dir, head)
    new_tail = move_tail(new_head, tail)
    move({dir, steps - 1}, new_head, new_tail)
  end

  defp move_2({_, 0}, head, long_tail), do: {head, long_tail}

  defp move_2({dir, steps}, head, long_tail) do
    new_head = move_head(dir, head)

    {_pos, reverse_nlt} =
      long_tail
      |> Enum.reduce({[new_head], []}, fn curr, {[prev | _] = coords, nlt} ->
        new_tail = move_tail(prev, curr)

        {[new_tail.pos | coords], [new_tail | nlt]}
      end)

    move_2({dir, steps - 1}, new_head, Enum.reverse(reverse_nlt))
  end

  defp move_head("L", {x, y}), do: {x - 1, y}
  defp move_head("R", {x, y}), do: {x + 1, y}
  defp move_head("U", {x, y}), do: {x, y + 1}
  defp move_head("D", {x, y}), do: {x, y - 1}

  defp move_tail({hx, hy}, %{pos: {tx, ty}, vis: v} = tail) do
    cond do
      abs(hx - tx) < 2 and abs(hy - ty) < 2 -> tail
      hx > tx and hy == ty -> %{tail | pos: {tx + 1, ty}, vis: MapSet.put(v, {tx + 1, ty})}
      hx < tx and hy == ty -> %{tail | pos: {tx - 1, ty}, vis: MapSet.put(v, {tx - 1, ty})}
      hy > ty and hx == tx -> %{tail | pos: {tx, ty + 1}, vis: MapSet.put(v, {tx, ty + 1})}
      hy < ty and hx == tx -> %{tail | pos: {tx, ty - 1}, vis: MapSet.put(v, {tx, ty - 1})}
      hx > tx and hy > ty -> %{tail | pos: {tx + 1, ty + 1}, vis: MapSet.put(v, {tx + 1, ty + 1})}
      hx < tx and hy < ty -> %{tail | pos: {tx - 1, ty - 1}, vis: MapSet.put(v, {tx - 1, ty - 1})}
      hx > tx and hy < ty -> %{tail | pos: {tx + 1, ty - 1}, vis: MapSet.put(v, {tx + 1, ty - 1})}
      hx < tx and hy > ty -> %{tail | pos: {tx - 1, ty + 1}, vis: MapSet.put(v, {tx - 1, ty + 1})}
    end
  end
end

input =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(fn s ->
    [dir, num] = String.split(s, " ")
    {dir, String.to_integer(num)}
  end)

# PART 1
input
|> Rope.exec()
|> then(fn {head, tail} ->
  tail.vis |> MapSet.size()
end)
|> IO.inspect()

# Part 2
{_, long_tail} =
  input
  |> Rope.exec_2()

long_tail
|> Enum.reverse()
|> hd()
|> then(& &1.vis)
|> MapSet.size()
|> IO.inspect()
