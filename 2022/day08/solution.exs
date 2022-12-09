defmodule ZipperList do
  defstruct [
    :focus,
    left: [],
    right: [],
    max_left: 0,
    max_right: 0,
    loc: {0, 0},
    viz: {0, 0},
    type: :row
  ]

  def new([h | t], loc \\ {0, 0}, type \\ :row) do
    r_viz = find_visibility(h, t)

    %ZipperList{focus: h, right: t, max_right: Enum.max(t), loc: loc, viz: {0, r_viz}, type: type}
  end

  def right(%ZipperList{
        focus: f,
        left: l,
        right: [h | t],
        max_left: ml,
        max_right: mr,
        loc: {x, y},
        type: type
      }) do
    max_l = if f > ml, do: f, else: ml
    max_r = if h >= mr and t != [], do: Enum.max(t), else: mr

    l_viz = if l == [], do: 1, else: find_visibility(h, [f | l])
    r_viz = if t == [], do: 0, else: find_visibility(h, t)

    new_loc = if type == :row, do: {x + 1, y}, else: {x, y + 1}

    %ZipperList{
      focus: h,
      left: [f | l],
      right: t,
      max_left: max_l,
      max_right: max_r,
      loc: new_loc,
      viz: {l_viz, r_viz},
      type: type
    }
  end

  defp find_visibility(focus, list) do
    blocking = list |> Enum.find_index(fn x -> x >= focus end)

    if blocking, do: blocking + 1, else: length(list)
  end
end

defmodule GridUtils do
  def make_row_zippers(data) do
    data |> Enum.with_index() |> Enum.map(fn {z, i} -> ZipperList.new(z, {0, i}) end)
  end

  def make_col_zippers(data) do
    data
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.with_index()
    |> Enum.map(fn {z, i} -> ZipperList.new(z, {i, 0}, :col) end)
  end

  def count_visible(z, visible \\ [])
  def count_visible(%{loc: loc, right: []}, visible), do: [loc | visible]

  def count_visible(%{loc: loc} = z, visible) do
    cond do
      z.left == [] ->
        count_visible(ZipperList.right(z), [loc | visible])

      z.focus > z.max_left or z.focus > z.max_right ->
        count_visible(ZipperList.right(z), [loc | visible])

      true ->
        count_visible(ZipperList.right(z), visible)
    end
  end

  def score_visibility(z, score_map \\ %{})
  def score_visibility(%{right: []} = z, score_map), do: Map.put(score_map, z.loc, z.viz)

  def score_visibility(z, score_map) do
    new_score = Map.put(score_map, z.loc, z.viz)
    score_visibility(ZipperList.right(z), new_score)
  end
end

data =
  File.read!("./input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))

rows = data |> GridUtils.make_row_zippers()
cols = data |> GridUtils.make_col_zippers()

# PART 1
visible_on_rows =
  rows
  |> Enum.map(&GridUtils.count_visible/1)
  |> Enum.map(&MapSet.new/1)
  |> Enum.reduce(MapSet.new(), fn m, acc -> MapSet.union(m, acc) end)

visible_on_cols =
  cols
  |> Enum.map(&GridUtils.count_visible/1)
  |> Enum.map(&MapSet.new/1)
  |> Enum.reduce(MapSet.new(), fn m, acc -> MapSet.union(m, acc) end)

MapSet.union(visible_on_rows, visible_on_cols)
|> MapSet.size()
|> IO.inspect()

# PART 2
row_scores =
  rows
  |> Enum.map(&GridUtils.score_visibility/1)
  |> Enum.reduce(%{}, &Map.merge(&1, &2))

col_scores =
  cols
  |> Enum.map(&GridUtils.score_visibility/1)
  |> Enum.reduce(%{}, &Map.merge(&1, &2))

row_scores
|> Enum.map(fn {k, v} -> 
  Tuple.product(v) * Tuple.product(col_scores[k])
end)
|> Enum.max()
|> IO.inspect()
