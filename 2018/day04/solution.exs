defmodule Record do
  defstruct [:timestamp, :id, :action]

  def new(string_data) do
    data =
      ~r/\[(?<timestamp>.*)\] (Guard #(?<id>\d+))? ?(?<action>\w+)/
      |> Regex.named_captures(string_data)
      |> Map.new(fn {k, v} ->
        v =
          case k do
            "timestamp" ->
              NaiveDateTime.from_iso8601!(v <> ":00")

            "id" ->
              if v == "", do: nil, else: String.to_integer(v)

            _ ->
              v
          end

        {String.to_atom(k), v}
      end)

    struct(Record, data)
  end
end

defmodule RecordUtils do
  def all_minutes_asleep(records) do
    do_all_minutes_asleep(records, nil, nil, %{})
  end

  defp do_all_minutes_asleep([], _, _, mins), do: mins

  defp do_all_minutes_asleep([h | t], current_id, begin, mins) do
    case h.action do
      "begins" ->
        do_all_minutes_asleep(t, h.id, begin, mins)

      "falls" ->
        id = h.id || current_id
        do_all_minutes_asleep(t, id, h.timestamp, mins)

      _ ->
        id = h.id || current_id
        minutes = begin.minute..(h.timestamp.minute - 1) |> Enum.to_list()

        new_mins =
          mins
          |> Map.update(id, minutes, fn x -> x ++ minutes end)

        do_all_minutes_asleep(t, id, begin, new_mins)
    end
  end
end

# Parse data into Record structs
records =
  File.stream!("./input.txt")
  |> Stream.reject(&(&1 == "\n"))
  |> Stream.map(fn line -> Record.new(line) end)
  |> Enum.to_list()
  |> Enum.sort(fn x, y ->
    case NaiveDateTime.compare(x.timestamp, y.timestamp) do
      :lt -> true
      _ -> false
    end
  end)

# PART 1
{gid, mins} =
  records
  |> RecordUtils.all_minutes_asleep()
  |> Enum.max_by(&length(elem(&1, 1)))

{mins_slept, _} =
  mins
  |> Enum.frequencies()
  |> Enum.max_by(&elem(&1, 1))

IO.puts("PART 1")
IO.puts(gid * mins_slept)

# PART 2
{gid_2, highest_min_freq} =
  records
  |> RecordUtils.all_minutes_asleep()
  |> Map.new(fn {k, v} -> {k, Enum.frequencies(v)} end)
  |> Enum.max_by(fn {_k, v} -> Enum.max(Map.values(v)) end)

{most_slept_min, _} =
  highest_min_freq
  |> Enum.max_by(&elem(&1, 1))

IO.puts("PART 2")
IO.puts(gid_2 * most_slept_min)
