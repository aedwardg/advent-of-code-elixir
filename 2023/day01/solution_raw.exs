regex = ~r/[[:digit:]]/

_nums =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Stream.map(&Regex.scan(regex, &1))
  |> Stream.map(fn list ->
    list = List.flatten(list)
    number = List.first(list) <> List.last(list)
    String.to_integer(number)
  end)
  |> Enum.to_list()
  |> Enum.sum()
  |> IO.inspect()

second_regex = ~r/(?=([[:digit:]]|one|two|three|four|five|six|seven|eight|nine))/

word_to_num = %{
  "one" => "1",
  "two" => "2",
  "three" => "3",
  "four" => "4",
  "five" => "5",
  "six" => "6",
  "seven" => "7",
  "eight" => "8",
  "nine" => "9"
}

_new_nums =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Stream.map(&Regex.scan(second_regex, &1))
  |> Stream.map(fn list ->
    list =
      list
      |> List.flatten()
      |> Enum.reject(& &1 == "")
      |> Enum.map(fn num ->
        if num in Map.keys(word_to_num), do: word_to_num[num], else: num
      end)

    number = List.first(list) <> List.last(list)
    String.to_integer(number)
  end)
  |> Enum.to_list()
  |> Enum.sum()
  |> IO.inspect()
