defmodule Claim do
  defstruct [:id, :left, :top, :width, :height]

  def new(string_data) do
    data =
      ~r/#(?<id>\d+) @ (?<left>\d+),(?<top>\d+): (?<width>\d+)x(?<height>\d+)/
      |> Regex.named_captures(string_data)
      |> Map.new(fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)

    struct(Claim, data)
  end
end

defmodule ClaimUtil do
  def claim_points(%Claim{} = claim) do
    for i <- (claim.left + 1)..(claim.left + claim.width),
        j <- (claim.top + 1)..(claim.top + claim.height),
        reduce: MapSet.new() do
      acc ->
        MapSet.put(acc, {i, j})
    end
  end

  def claim_points(claims) when is_list(claims) do
    for claim <- claims,
        i <- (claim.left + 1)..(claim.left + claim.width),
        j <- (claim.top + 1)..(claim.top + claim.height) do
      {i, j}
    end
  end

  def claim_overlaps(claims) do
    claim_points(claims)
    |> Enum.frequencies()
    |> Enum.reduce(MapSet.new(), fn {k, v}, acc -> 
      if v > 1, do: MapSet.put(acc, k), else: acc
    end)
  end

  def claims_without_overlap(claims) do
    do_claims_without_overlap(claims, claim_overlaps(claims))
  end

  defp do_claims_without_overlap([], _), do: nil

  defp do_claims_without_overlap([claim | t], overlaps) do
    points = claim_points(claim)

    if MapSet.difference(points, overlaps) == points do
      claim.id
    else
      do_claims_without_overlap(t, overlaps)
    end
  end
end

# Parse data into Claim structs
claims =
  File.stream!("./input.txt")
  |> Stream.reject(&(&1 == "\n"))
  |> Stream.map(fn line -> Claim.new(line) end)
  |> Enum.to_list()

# PART 1
overlaps =
  claims
  |> ClaimUtil.claim_overlaps()
  |> Enum.count()

IO.puts("PART 1")
IO.puts(overlaps)

# PART 2
isolated =
  claims
  |> ClaimUtil.claims_without_overlap()

IO.puts("PART 2")
IO.puts(isolated)
