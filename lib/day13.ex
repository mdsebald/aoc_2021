defmodule Day13 do
  @moduledoc """

  --- Day 13: Transparent Origami ---
  You reach another volcanically active part of the cave. It would be nice if
  you could do some kind of thermal imaging so you could tell ahead of time
  which caves are too hot to safely enter.

  Fortunately, the submarine seems to be equipped with a thermal camera! When
  you activate it, you are greeted with:

  Congratulations on your purchase! To activate this infrared thermal imaging
  camera system, please enter the code found on page 1 of the manual.

  Apparently, the Elves have never used this feature. To your surprise, you
  manage to find the manual; as you go to open it, page 1 falls out. It's a
  large sheet of transparent paper! The transparent paper is marked with
  random dots and includes instructions on how to fold it up (your puzzle
  input). For example:

  6,10
  0,14
  9,10
  0,3
  10,4
  4,11
  6,0
  6,12
  4,1
  0,13
  10,12
  3,4
  3,0
  8,4
  1,10
  2,14
  8,10
  9,0

  fold along y=7
  fold along x=5

  The first section is a list of dots on the transparent paper. 0,0
  represents the top-left coordinate. The first value, x, increases to the
  right. The second value, y, increases downward. So, the coordinate 3,0 is
  to the right of 0,0, and the coordinate 0,7 is below 0,0. The coordinates
  in this example form the following pattern, where # is a dot on the paper
  and . is an empty, unmarked position:

  ...#..#..#.
  ....#......
  ...........
  #..........
  ...#....#.#
  ...........
  ...........
  ...........
  ...........
  ...........
  .#....#.##.
  ....#......
  ......#...#
  #..........
  #.#........

  Then, there is a list of fold instructions. Each instruction indicates a
  line on the transparent paper and wants you to fold the paper up (for
  horizontal y=... lines) or left (for vertical x=... lines). In this
  example, the first fold instruction is fold along y=7, which designates the
  line formed by all of the positions where y is 7 (marked here with -):

  ...#..#..#.
  ....#......
  ...........
  #..........
  ...#....#.#
  ...........
  ...........
  -----------
  ...........
  ...........
  .#....#.##.
  ....#......
  ......#...#
  #..........
  #.#........

  Because this is a horizontal line, fold the bottom half up. Some of the
  dots might end up overlapping after the fold is complete, but dots will
  never appear exactly on a fold line. The result of doing this fold looks
  like this:

  #.##..#..#.
  #...#......
  ......#...#
  #...#......
  .#.#..#.###
  ...........
  ...........

  Now, only 17 dots are visible.

  Notice, for example, the two dots in the bottom left corner before the
  transparent paper is folded; after the fold is complete, those dots appear
  in the top left corner (at 0,0 and 0,1). Because the paper is transparent,
  the dot just below them in the result (at 0,3) remains visible, as it can
  be seen through the transparent paper.

  Also notice that some dots can end up overlapping; in this case, the dots
  merge together and become a single dot.

  The second fold instruction is fold along x=5, which indicates this line:

  #.##.|#..#.
  #...#|.....
  .....|#...#
  #...#|.....
  .#.#.|#.###
  .....|.....
  .....|.....

  Because this is a vertical line, fold left:

  #####
  #...#
  #...#
  #...#
  #####
  .....
  .....
  The instructions made a square!

  The transparent paper is pretty big, so for now, focus on just completing
  the first fold. After the first fold in the example above, 17 dots are
  visible - dots that end up overlapping after the fold is completed count as
  a single dot.

  How many dots are visible after completing just the first fold instruction
  on your transparent paper?

  Your puzzle answer was 607.
  """

  def first_fold_visible_dot_count() do
    {dots, folds} = get_instructions()

    do_fold(dots, Enum.at(folds, 0)) |> Enum.count()
  end

  @doc """
  Finish folding the transparent paper according to the instructions. The manual says the code is always eight capital letters.

  What code do you use to activate the infrared thermal imaging camera system?

  Your puzzle answer was CPZLPFZL.
  """

  def finish_folding_instructions() do
    {dots, folds} = get_instructions()
    Enum.reduce(folds, dots, fn fold, dots ->
      do_fold(dots, fold)
    end)
    |> print_activation_code()
  end

  defp print_activation_code(dots) do
    {max_x, max_y} = Enum.sort(dots) |> List.last()

    IO.puts("\n")
    Enum.each(0..max_y, fn y ->
      IO.puts(build_dot_line(dots, max_x, y))
    end)
  end

  defp build_dot_line(dots, max_x, curr_y) do
    Enum.reduce(0..max_x, _line = "", fn x, line ->
      if Enum.member?(dots, {x, curr_y}) do
        line <> "*"
      else
        line <> " "
      end
    end)
  end

  # Common functions

  defp get_instructions(input_file \\ "inputs/day13.txt") do
    File.read!(input_file)
    |> String.split("\n", trim: true)
    |> Enum.reduce({_dots = [], _folds = []}, fn line, {dots, folds} ->
      if String.contains?(line, ",") do
        {[get_dot(line) | dots], folds}
      else
        # must be a fold, (Order matters. Add to end of folds list)
        {dots, folds ++ [get_fold(line)]}
      end
    end)
  end

  defp get_dot(dot_str) do
    [x_str, y_str] = String.split(dot_str, ",")
    {String.to_integer(x_str), String.to_integer(y_str)}
  end

  defp get_fold(fold_str) do
    [dir_str, fold_line_str] = String.split(fold_str, "=")
    fold_line = String.to_integer(fold_line_str)

    case dir_str do
      "fold along x" -> {:x, fold_line}
      "fold along y" -> {:y, fold_line}
    end
  end

  defp do_fold(dots, {:x, fold_line}) do
    Enum.map(dots, fn {x, y} -> {fold_dot(x, fold_line), y} end)
    |> Enum.uniq()
  end

  defp do_fold(dots, {:y, fold_line}) do
    Enum.map(dots, fn {x, y} -> {x, fold_dot(y, fold_line)} end)
    |> Enum.uniq()
  end

  defp fold_dot(dot, fold_line) when dot > fold_line do
    dot - 2 * (dot - fold_line)
  end

  defp fold_dot(dot, _fold_line), do: dot
end
