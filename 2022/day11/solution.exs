# Monkey Struct and Module
defmodule Monkey do
  defstruct [:id, :operation, :test, :divisor, items: [], inspected: 0]

  def new([id_data, item_data, op_data, test_data, t_data, f_data]) do
    id = parse_id(id_data)
    items = parse_items(item_data)
    operation = parse_operation(op_data)
    div = parse_divisor(test_data)
    test = parse_test(div, t_data, f_data)

    %Monkey{id: id, items: items, operation: operation, test: test, divisor: div}
  end

  defp parse_id("Monkey " <> id) do
    {id, _} = String.split_at(id, -1)
    String.to_integer(id)
  end

  defp parse_items("Starting items: " <> items) do
    items
    |> String.split(", ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_operation("Operation: new = " <> op) do
    case op do
      "old + " <> num -> &(&1 + String.to_integer(num))
      "old * old" -> &(&1 * &1)
      "old * " <> num -> &(&1 * String.to_integer(num))
    end
  end

  defp parse_divisor("Test: divisible by " <> div), do: String.to_integer(div)

  defp parse_test(div, true_case, false_case) do
    "If true: throw to monkey " <> t_id = true_case
    "If false: throw to monkey " <> f_id = false_case

    [t_id, f_id] = [t_id, f_id] |> Enum.map(&String.to_integer/1)

    fn n -> if rem(n, div) == 0, do: t_id, else: f_id end
  end
end

# KeepAway game logic module
defmodule KeepAway do
  def round(monkeys, lcm \\ nil) do
    0..(length(Map.keys(monkeys)) - 1)
    |> Enum.reduce(monkeys, fn i, monkeys ->
      take_turn(monkeys[i], monkeys, lcm)
    end)
  end

  defp take_turn(%Monkey{items: []}, monkeys, _), do: monkeys

  defp take_turn(%Monkey{id: id, items: [h | t]} = m, monkeys, lcm) do
    inspected = m.inspected + 1
    value = if !lcm, do: div(m.operation.(h), 3), else: m.operation.(h)
    next = m.test.(value)

    next_items =
      if !lcm, do: monkeys[next].items ++ [value], else: monkeys[next].items ++ [rem(value, lcm)]

    new_m = %Monkey{m | items: t, inspected: inspected}
    new_next = %Monkey{monkeys[next] | items: next_items}
    new_monkeys = %{monkeys | id => new_m, next => new_next}

    take_turn(new_m, new_monkeys, lcm)
  end

  def monkey_business(monkeys) do
    monkeys
    |> Enum.map(fn {_, m} ->
      m.inspected
    end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end
end

# Parse the monkey data
monkeys =
  File.read!("./input.txt")
  |> String.split("\n\n", trim: true)
  |> Enum.map(fn s ->
    String.split(s, "\n", trim: true)
    |> Enum.map(&String.trim/1)
  end)
  |> Enum.reduce(%{}, fn data, acc ->
    monkey = Monkey.new(data)
    Map.put(acc, monkey.id, monkey)
  end)

# PART 1
1..20
|> Enum.reduce(monkeys, fn _, monkeys ->
  KeepAway.round(monkeys)
end)
|> KeepAway.monkey_business()
|> IO.inspect()

# PART 2
least_common_multiple =
  monkeys
  |> Enum.map(&elem(&1, 1).divisor)
  |> Enum.reduce(1, fn num, acc ->
    div(num * acc, Integer.gcd(num, acc))
  end)

1..10_000
|> Enum.reduce(monkeys, fn _, monkeys ->
  KeepAway.round(monkeys, least_common_multiple)
end)
|> KeepAway.monkey_business()
|> IO.inspect()
