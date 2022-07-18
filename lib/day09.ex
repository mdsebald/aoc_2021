defmodule Day09 do
  @moduledoc """
  --- Day 9: Smoke Basin ---
  These caves seem to be lava tubes. Parts are even still volcanically
  active; small hydrothermal vents release smoke into the caves that slowly
  settles like rain.

  If you can model how the smoke flows through the caves, you might be able
  to avoid it and be that much safer. The submarine generates a heightmap of
  the floor of the nearby caves for you (your puzzle input).

  Smoke flows to the lowest point of the area it's in. For example, consider
  the following heightmap:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  Each number corresponds to the height of a particular location, where 9 is
  the highest and 0 is the lowest a location can be.

  Your first goal is to find the low points - the locations that are lower
  than any of its adjacent locations. Most locations have four adjacent
  locations (up, down, left, and right); locations on the edge or corner of
  the map have three or two adjacent locations, respectively. (Diagonal
  locations do not count as adjacent.)

  In the above example, there are four low points, all highlighted: two are
  in the first row (a 1 and a 0), one is in the third row (a 5), and one is
  in the bottom row (also a 5). All other locations on the heightmap have
  some lower adjacent location, and so are not low points.

  The risk level of a low point is 1 plus its height. In the above example,
  the risk levels of the low points are 2, 1, 6, and 6. The sum of the risk
  levels of all low points in the heightmap is therefore 15.

  Find all of the low points on your heightmap. What is the sum of the risk
  levels of all low points on your heightmap?

  Your puzzle answer was 591.
  """

  def sum_risk_levels() do
    get_heightmap()
    |> find_low_points()
    |> sum_low_points()
  end

  @doc """
  --- Part Two ---
  Next, you need to find the largest basins so you know what areas are most
  important to avoid.

  A basin is all locations that eventually flow downward to a single low
  point. Therefore, every low point has a basin, although some basins are
  very small. Locations of height 9 do not count as being in any basin, and
  all other locations will always be part of exactly one basin.

  The size of a basin is the number of locations within the basin, including
  the low point. The example above has four basins.

  The top-left basin, size 3:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  The top-right basin, size 9:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  The middle basin, size 14:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  The bottom-right basin, size 9:

  2199943210
  3987894921
  9856789892
  8767896789
  9899965678

  Find the three largest basins and multiply their sizes together. In the
  above example, this is 9 * 14 * 9 = 1134.

  What do you get if you multiply together the sizes of the three largest
  basins?

  Your puzzle answer was 1113424.
  """

  def find_basins() do
    heightmap = get_heightmap()

    find_low_points(heightmap)
    |> Enum.map(&find_basin(heightmap, &1))
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp find_basin(heightmap, low_point) do
    do_find_basin(heightmap, [low_point], MapSet.new())
  end

  defp do_find_basin(_heightmap, [], seen), do: seen

  defp do_find_basin(heightmap, [low_point | rem_low_points], seen) do
    adj =
      get_adj_points(heightmap, low_point)
      |> Enum.reject(&MapSet.member?(seen, &1))
      |> Enum.filter(fn {_, _, adj_height} ->
        {_, _, point_height} = low_point
        adj_height > point_height and adj_height != 9
      end)

    do_find_basin(heightmap, rem_low_points ++ adj, MapSet.put(seen, low_point))
  end

  # Common functions

  defp get_heightmap(input_file \\ "inputs/day09.txt") do
    File.read!(input_file)
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&to_ints/1)
  end

  defp to_ints(num_chars) do
    Enum.map(num_chars, &(&1 - ?0))
  end

  defp find_low_points(heightmap) do
    Enum.reduce(0..(length(heightmap) - 1), _low_points = [], fn row_idx, low_points ->
      low_points ++ find_row_low_points(heightmap, row_idx)
    end)
  end

  defp find_row_low_points(heightmap, row_idx) do
    adj_rows = {_, curr_row, _} = get_adj_rows(heightmap, row_idx)

    Enum.reduce(
      0..(length(curr_row) - 1),
      _row_low_points = [],
      fn col_idx, row_low_points ->
        curr_height = Enum.at(curr_row, col_idx)

        if lt_left?(curr_height, adj_rows, col_idx) and
             lt_right?(curr_height, adj_rows, col_idx) and
             lt_above?(curr_height, adj_rows, col_idx) and
             lt_below?(curr_height, adj_rows, col_idx) do
          # we have found a low point
          [{row_idx, col_idx, curr_height} | row_low_points]
        else
          row_low_points
        end
      end
    )
  end

  defp get_adj_rows(heightmap, row_idx) do
    {
      if row_idx > 0 do
        Enum.at(heightmap, row_idx - 1)
      else
        []
      end,
      Enum.at(heightmap, row_idx),
      Enum.at(heightmap, row_idx + 1, [])
    }
  end

  defp get_adj_points(heightmap, {row_idx, col_idx, _height}) do
    {prev_row, curr_row, next_row} = get_adj_rows(heightmap, row_idx)

    left =
      if col_idx > 0 do
        {row_idx, col_idx - 1, Enum.at(curr_row, col_idx - 1)}
      else
        nil
      end

    right =
      if col_idx < length(curr_row) - 1 do
        {row_idx, col_idx + 1, Enum.at(curr_row, col_idx + 1)}
      else
        nil
      end

    above =
      if prev_row != [] do
        {row_idx - 1, col_idx, Enum.at(prev_row, col_idx)}
      else
        nil
      end

    below =
      if next_row != [] do
        {row_idx + 1, col_idx, Enum.at(next_row, col_idx)}
      else
        nil
      end

    Enum.filter([left, right, above, below], fn point -> point != nil end)
  end

  defp lt_left?(_curr_height, _adj_rows, 0), do: true

  defp lt_left?(curr_height, {_, curr_row, _}, col_idx),
    do: curr_height < Enum.at(curr_row, col_idx - 1)

  defp lt_right?(_curr_height, {_, curr_row, _}, col_idx) when col_idx == length(curr_row) - 1,
    do: true

  defp lt_right?(curr_height, {_, curr_row, _}, col_idx),
    do: curr_height < Enum.at(curr_row, col_idx + 1)

  defp lt_above?(_curr_height, {[], _, _}, _col_idx), do: true

  defp lt_above?(curr_height, {prev_row, _, _}, col_idx),
    do: curr_height < Enum.at(prev_row, col_idx)

  defp lt_below?(_curr_height, {_, _, []}, _col_idx), do: true

  defp lt_below?(curr_height, {_, _, next_row}, col_idx),
    do: curr_height < Enum.at(next_row, col_idx)

  defp sum_low_points(low_points) do
    Enum.reduce(low_points, _total = 0, fn {_row, _col, low_point}, total ->
      total + low_point + 1
    end)
  end
end
