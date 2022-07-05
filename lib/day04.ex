defmodule Day04 do
  @moduledoc """
  --- Day 4: Giant Squid ---
  You're already almost 1.5km (almost a mile) below the surface of the ocean,
  already so deep that you can't see any sunlight. What you can see, however,
  is a giant squid that has attached itself to the outside of your submarine.

  Maybe it wants to play bingo?

  Bingo is played on a set of boards each consisting of a 5x5 grid of
  numbers. Numbers are chosen at random, and the chosen number is marked on
  all boards on which it appears. (Numbers may not appear on all boards.) If
  all numbers in any row or any column of a board are marked, that board
  wins. (Diagonals don't count.)

  The submarine has a bingo subsystem to help passengers (currently, you and
  the giant squid) pass the time. It automatically generates a random order
  in which to draw numbers and a random set of boards (your puzzle input).
  For example:

  7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

  22 13 17 11  0
   8  2 23  4 24
  21  9 14 16  7
   6 10  3 18  5
   1 12 20 15 19

   3 15  0  2 22
   9 18 13 17  5
  19  8  7 25 23
  20 11 10 24  4
  14 21 16 12  6

  14 21 17 24  4
  10 16 15  9 19
  18  8 23 26 20
  22 11 13  6  5
   2  0 12  3  7

  After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no
  winners, but the boards are marked as follows (shown here adjacent to each
  other to save space):

  22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
   8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
  21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
   6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
   1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

  After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are
  still no winners:

  22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
   8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
  21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
   6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
   1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

  Finally, 24 is drawn:

  22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
   8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
  21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
   6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
   1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

  At this point, the third board wins because it has at least one complete
  row or column of marked numbers (in this case, the entire top row is
  marked: 14 21 17 24 4).

  The score of the winning board can now be calculated. Start by finding the
  sum of all unmarked numbers on that board; in this case, the sum is 188.
  Then, multiply that sum by the number that was just called when the board
  won, 24, to get the final score, 188 * 24 = 4512.

  To guarantee victory against the giant squid, figure out which board will
  win first. What will your final score be if you choose that board?

  Your puzzle answer was 63552.
  """

  @board_size 5

  #
  # Represent each place on each board with a map:
  #   %{col: integer(0..(@board_size - 1)),
  #     row: integer(0..(@board_size - 1)),
  #     marked: bool,
  #     val: integer}
  #
  # Represent each board with a map:
  #   %{winning_move: integer(0..99)
  #     places: list(place maps)}
  #
  # Represent all boards with list of board maps
  #   [board_map.0, board_map.1, .., board_map.qty_boards]
  #

  def calc_winning_score() do
    {boards, moves} = get_bingo_game()
    winning_board = play_bingo_to_first_win(boards, moves)
    calc_score(winning_board)
  end

  defp play_bingo_to_first_win(boards, moves) do
    Enum.reduce_while(moves, boards, fn move, boards ->
      boards = mark_boards(boards, move)
      # check for a winning board after each move
      case winning_boards(boards) do
        [] -> {:cont, boards}
        [winning_board] -> {:halt, winning_board}
      end
    end)
  end

  @doc """
  --- Part Two ---
  On the other hand, it might be wise to try a different strategy: let the
  giant squid win.

  You aren't sure how many bingo boards a giant squid could play at once, so
  rather than waste time counting its arms, the safe thing to do is to figure
  out which board will win last and choose that one. That way, no matter
  which boards it picks, it will win for sure.

  In the above example, the second board is the last to win, which happens
  after 13 is eventually called and its middle column is completely marked.
  If you were to keep playing until this point, the second board would have a
  sum of unmarked numbers equal to 148 for a final score of 148 * 13 = 1924.

  Figure out which board will win last. Once it wins, what would its final
  score be?

  Your puzzle answer was 9020.
  """

  def calc_last_winning_score() do
    {boards, moves} = get_bingo_game()
    last_winning_board = play_bingo_to_last_win(boards, moves)
    calc_score(last_winning_board)
  end

  defp play_bingo_to_last_win(boards, moves) do
    # Play all of the moves, ignore winning board(s) for now
    boards =
      Enum.reduce(moves, boards, fn move, boards ->
        mark_boards(boards, move)
      end)

    last_winning_board = last_winning_board(boards, moves)
    last_winning_move = last_winning_board[:winning_move]

    # Undo the moves one by one, in reverse,
    # until the last winning move
    moves
    |> Enum.reverse()
    |> Enum.reduce_while(last_winning_board, fn move, board ->
      if move != last_winning_move do
        places = board[:places]

        places =
          Enum.map(places, fn place ->
            unmark_place(place, move)
          end)

        {:cont, Map.put(board, :places, places)}
      else
        {:halt, board}
      end
    end)
  end

  # Common functions

  defp get_bingo_game(input_file \\ "inputs/day04_input.txt") do
    [raw_moves | raw_rows] =
      File.read!(input_file)
      |> String.split("\n", trim: true)

    moves = parse_moves(raw_moves)
    boards = parse_boards(raw_rows)

    {boards, moves}
  end

  defp parse_moves(raw_moves) do
    String.split(raw_moves, ",")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_boards(raw_rows) do
    {boards, curr_places, _curr_row} =
      Enum.reduce(
        raw_rows,
        {_boards = [], _places = [], _curr_row = 0},
        fn raw_row, {boards, curr_places, curr_row} ->
          {boards, curr_places, curr_row} =
            if curr_row == @board_size do
              {add_board(boards, curr_places), [], 0}
            else
              {boards, curr_places, curr_row}
            end

          curr_places = curr_places ++ parse_row(raw_row, curr_row)
          {boards, curr_places, curr_row + 1}
        end
      )

    # Tack on the last board
    add_board(boards, curr_places)
  end

  defp parse_row(raw_row, row_num) do
    {_col_num, places} =
      raw_row
      |> String.split()
      |> Enum.map(&String.to_integer/1)
      |> Enum.reduce({_col_num = 0, _places = []}, fn value, {col_num, places} ->
        new_place = %{col: col_num, row: row_num, val: value, marked: false}
        {col_num + 1, [new_place | places]}
      end)

    Enum.reverse(places)
  end

  defp add_board(boards, places) do
    boards ++ [%{winning_move: nil, places: places}]
  end

  defp mark_boards(boards, move) do
    Enum.map(boards, fn board ->
      places = board[:places]

      places =
        Enum.map(places, fn place ->
          mark_place(place, move)
        end)

      board = Map.put(board, :places, places)
      mark_winning_board(board, move)
    end)
  end

  defp mark_place(place, move) do
    if place[:val] == move do
      Map.put(place, :marked, true)
    else
      place
    end
  end

  defp unmark_place(place, move) do
    if place[:val] == move do
      Map.put(place, :marked, false)
    else
      place
    end
  end

  defp mark_winning_board(board, move) do
    if board[:winning_move] == nil and winning_board?(board) do
      Map.put(board, :winning_move, move)
    else
      board
    end
  end

  defp winning_board?(board) do
    init_col_hits = init_hit_counters()
    init_row_hits = init_hit_counters()

    {col_hits, row_hits} =
      board[:places]
      |> Enum.filter(fn place -> place[:marked] == true end)
      |> Enum.reduce({init_col_hits, init_row_hits}, fn place, {col_hits, row_hits} ->
        {incr_hit_counter(col_hits, place[:col]), incr_hit_counter(row_hits, place[:row])}
      end)

    winning_hit_count?(col_hits) or winning_hit_count?(row_hits)
  end

  defp init_hit_counters() do
    Enum.map(1..@board_size, fn _index -> 0 end)
  end

  defp incr_hit_counter(hit_counters, index) do
    new_count = Enum.at(hit_counters, index) + 1
    List.replace_at(hit_counters, index, new_count)
  end

  defp winning_hit_count?(hit_counters) do
    Enum.any?(hit_counters, fn hit_counter -> hit_counter == @board_size end)
  end

  defp winning_boards(boards) do
    Enum.filter(boards, fn board -> board[:winning_move] != nil end)
  end

  defp last_winning_board(boards, moves) do
    {last_winning_board, _last_winning_move_index} =
      winning_boards(boards)
      |> Enum.reduce({_last_winning_board = nil, _last_winning_move_index = 0}, fn board,
                                                                                   {last_winning_board,
                                                                                    last_winning_move_index} ->
        winning_move_index = Enum.find_index(moves, fn move -> board[:winning_move] == move end)

        if winning_move_index > last_winning_move_index do
          {board, winning_move_index}
        else
          {last_winning_board, last_winning_move_index}
        end
      end)

    last_winning_board
  end

  defp calc_score(winning_board) do
    # print_board(winning_board)
    unmarked_total =
      winning_board[:places]
      |> Enum.reject(fn place -> place[:marked] == true end)
      |> Enum.reduce(_unmarked_total = 0, fn place, unmarked_total ->
        place[:val] + unmarked_total
      end)

    unmarked_total * winning_board[:winning_move]
  end

  def print_board(board) do
    IO.puts("Board: #{inspect(board)}")
  end
end
