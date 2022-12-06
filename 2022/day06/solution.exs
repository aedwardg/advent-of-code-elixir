defmodule Comms do
  def first_packet_marker([one, two, three, four | t]) do
    do_first_packet_marker({one, two, three, four}, t, 4)
  end

  defp do_first_packet_marker({one, two, three, four}, [h | t], count) do
    if length(Enum.uniq([one, two, three, four])) == 4 do
      count
    else
      do_first_packet_marker({two, three, four, h}, t, count + 1)
    end
  end

  def start_of_message([a, b, c, d, e, f, g, h, i, j, k, l, m, n | rest]) do
    do_start_of_message({a, b, c, d, e, f, g, h, i, j, k, l, m, n}, rest, 14)
  end

  defp do_start_of_message({a, b, c, d, e, f, g, h, i, j, k, l, m, n}, [head | tail], count) do
    if length(Enum.uniq([a, b, c, d, e, f, g, h, i, j, k, l, m, n])) == 14 do
      count
    else
      do_start_of_message({b, c, d, e, f, g, h, i, j, k, l, m, n, head}, tail, count + 1)
    end
  end
end

File.read!("./input.txt")
|> String.trim()
|> String.split("", trim: true)
|> tap(&IO.inspect(Comms.first_packet_marker(&1)))
|> Comms.start_of_message()
|> IO.inspect()
