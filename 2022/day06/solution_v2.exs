defmodule Comms do
  def find_marker(data, size) do
    <<chunk::bytes-size(size), rest::binary>> = data
    do_find_marker(chunk, rest, size, size)
  end

  defp do_find_marker(<<_, b::binary>> = chunk, <<next, rest::binary>>, size, count) do
    set = chunk |> String.to_charlist() |> MapSet.new()

    if MapSet.size(set) == size,
      do: count,
      else: do_find_marker(<<b::binary, next>>, rest, size, count + 1)
  end
end

File.read!("./input.txt")
|> tap(&IO.inspect(Comms.find_marker(&1, 4)))
|> Comms.find_marker(14)
|> IO.inspect()
