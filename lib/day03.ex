defmodule Day03 do
  @moduledoc """
  --- Day 3: Binary Diagnostic ---
  The submarine has been making some odd creaking noises, so you ask it to
  produce a diagnostic report just in case.

  The diagnostic report (your puzzle input) consists of a list of binary
  numbers which, when decoded properly, can tell you many useful things about
  the conditions of the submarine. The first parameter to check is the power
  consumption.

  You need to use the binary numbers in the diagnostic report to generate two
  new binary numbers (called the gamma rate and the epsilon rate). The power
  consumption can then be found by multiplying the gamma rate by the epsilon rate.

  Each bit in the gamma rate can be determined by finding the most common bit
  in the corresponding position of all numbers in the diagnostic report. For
  example, given the following diagnostic report:

  00100
  11110
  10110
  10111
  10101
  01111
  00111
  11100
  10000
  11001
  00010
  01010

  Considering only the first bit of each number, there are five 0 bits and
  seven 1 bits. Since the most common bit is 1, the first bit of the gamma
  rate is 1.

  The most common second bit of the numbers in the diagnostic report is 0, so
  the second bit of the gamma rate is 0.

  The most common value of the third, fourth, and fifth bits are 1, 1, and 0,
  respectively, and so the final three bits of the gamma rate are 110.

  So, the gamma rate is the binary number 10110, or 22 in decimal.

  The epsilon rate is calculated in a similar way; rather than use the most
  common bit, the least common bit from each position is used. So, the
  epsilon rate is 01001, or 9 in decimal. Multiplying the gamma rate (22) by
  the epsilon rate (9) produces the power consumption, 198.

  Use the binary numbers in your diagnostic report to calculate the
  gamma rate and epsilon rate, then multiply them together. What is the power
  consumption of the submarine? (Be sure to represent your answer in decimal,
  not binary.)

  Your puzzle answer was 2035764.
  """

  def calc_power_consumption() do
    get_diag_report()
    |> Enum.reduce(_bit_counters = %{}, fn diag_value, bit_counters ->
      count_ones_and_zeros(diag_value, bit_counters)
    end)
    |> generate_gamma_and_epsilon_bit_lists()
    |> convert_gamma_and_epsilon_bits_to_numbers()
    |> convert_gamma_and_epsilon_to_power()
  end

  # Create initial counters
  defp count_ones_and_zeros(diag_value, bit_counters)
       when bit_counters == %{} do
    # IO.puts("init counters")
    bin_num_len = length(diag_value)

    bit_counters =
      List.duplicate(0, bin_num_len)
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.into(%{})

    count_ones_and_zeros(diag_value, bit_counters)
  end

  # When the count is > 0, there are more '1's
  # When the count is < 0, there are more '0's
  defp count_ones_and_zeros(diag_value, bit_counters) do
    # IO.puts("diag_value: #{diag_value}, counters: #{inspect(bit_counters)}")

    {bit_counters, _index} =
      Enum.reduce(diag_value, {bit_counters, _index = 0}, fn diag_digit, {bit_counters, index} ->
        case diag_digit do
          ?1 ->
            count = bit_counters[index] + 1
            bit_counters = Map.put(bit_counters, index, count)
            {bit_counters, index + 1}

          ?0 ->
            count = bit_counters[index] - 1
            bit_counters = Map.put(bit_counters, index, count)
            {bit_counters, index + 1}
        end
      end)

    bit_counters
  end

  defp generate_gamma_and_epsilon_bit_lists(bit_counters) do
    Enum.reduce_while(0..999, {[], []}, fn index, {gamma, epsilon} ->
      case Map.get(bit_counters, index) do
        nil ->
          {:halt, {gamma, epsilon}}

        count when count > 0 ->
          {:cont, {gamma ++ [?1], epsilon ++ [?0]}}

        count when count < 0 ->
          {:cont, {gamma ++ [?0], epsilon ++ [?1]}}
      end
    end)
  end

  defp convert_gamma_and_epsilon_bits_to_numbers({gamma_bit_list, epsilon_bit_list}) do
    gamma = bit_list_to_number(gamma_bit_list)
    epsilon = bit_list_to_number(epsilon_bit_list)
    {gamma, epsilon}
  end

  defp bit_list_to_number(bit_list) do
    to_string(bit_list) |> String.to_integer(2)
  end

  defp convert_gamma_and_epsilon_to_power({gamma, epsilon}) do
    gamma * epsilon
  end

  @doc """
  --- Part Two ---
  Next, you should verify the life support rating, which can be determined by
  multiplying the oxygen generator rating by the CO2 scrubber rating.

  Both the oxygen generator rating and the CO2 scrubber rating are values
  that can be found in your diagnostic report - finding them is the tricky
  part. Both values are located using a similar process that involves
  filtering out values until only one remains. Before searching for either
  rating value, start with the full list of binary numbers from your
  diagnostic report and consider just the first bit of those numbers. Then:

    - Keep only numbers selected by the bit criteria for the type of rating
      value for which you are searching. Discard numbers which do not match
      the bit criteria.
    - If you only have one number left, stop; this is the rating value for
      which you are searching.
    - Otherwise, repeat the process, considering the next bit to the right.

  The bit criteria depends on which type of rating value you want to find:

    - To find oxygen generator rating, determine the most common value (0 or
      1) in the current bit position, and keep only numbers with that bit in
      that position. If 0 and 1 are equally common, keep values with a 1 in
      the position being considered.
    - To find CO2 scrubber rating, determine the least common value (0 or 1)
      in the current bit position, and keep only numbers with that bit in
      that position. If 0 and 1 are equally common, keep values with a 0 in
      the position being considered.

  For example, to determine the oxygen generator rating value using the same
  example diagnostic report from above:

    - Start with all 12 numbers and consider only the first bit of each
      number. There are more 1 bits (7) than 0 bits (5), so keep only the 7
      numbers with a 1 in the first position: 11110, 10110, 10111, 10101,
      11100, 10000, and 11001.
    - Then, consider the second bit of the 7 remaining numbers: there are
      more 0 bits (4) than 1 bits (3), so keep only the 4 numbers with a 0
      in the second position: 10110, 10111, 10101, and 10000.
    - In the third position, three of the four numbers have a 1, so keep
      those three: 10110, 10111, and 10101.
    - In the fourth position, two of the three numbers have a 1, so keep
      those two: 10110 and 10111.
    - In the fifth position, there are an equal number of 0 bits and 1 bits
      (one each). So, to find the oxygen generator rating, keep the number
      with a 1 in that position: 10111.
    - As there is only one number left, stop; the oxygen generator rating is
      10111, or 23 in decimal.

  Then, to determine the CO2 scrubber rating value from the same example
  above:

    - Start again with all 12 numbers and consider only the first bit of
      each number. There are fewer 0 bits (5) than 1 bits (7), so keep only
      the 5 numbers with a 0 in the first position: 00100, 01111, 00111,
      00010, and 01010.
    - Then, consider the second bit of the 5 remaining numbers: there are
      fewer 1 bits (2) than 0 bits (3), so keep only the 2 numbers with a 1
      in the second position: 01111 and 01010.
    - In the third position, there are an equal number of 0 bits and 1 bits
      (one each). So, to find the CO2 scrubber rating, keep the number with
      a 0 in that position: 01010.
    - As there is only one number left, stop; the CO2 scrubber rating is
      01010, or 10 in decimal.

  Finally, to find the life support rating, multiply the oxygen generator
  rating (23) by the CO2 scrubber rating (10) to get 230.

  Use the binary numbers in your diagnostic report to calculate the oxygen
  generator rating and CO2 scrubber rating, then multiply them together. What
  is the life support rating of the submarine? (Be sure to represent your
  answer in decimal, not binary.)

  Your puzzle answer was 2817661
  """
  def calc_life_support_rating() do
    diag_report = get_diag_report()

    o2 = find_o2(diag_report, 0)
    co2 = find_co2(diag_report, 0)

    o2 * co2
  end

  defp find_o2([o2_rating_list], _index) do
    #IO.inspect("Final O2 Rating: #{o2_rating_list}\n")
    to_string(o2_rating_list) |> String.to_integer(2)
  end

  defp find_o2(diag_report, index) do
    #IO.inspect("O2 Diag Reports: #{inspect(diag_report)} Index: #{index}")
    majority_bit = find_majority_bit(diag_report, index)

    filtered_diag_report =
      Enum.filter(diag_report, fn diag_report ->
        Enum.at(diag_report, index) == majority_bit
      end)

    find_o2(filtered_diag_report, index + 1)
  end

  defp find_majority_bit(diag_report, index) do
    {ones_count, zeros_count} =
      Enum.reduce(diag_report, {_ones_count = 0, _zeros_count = 0}, fn diag_value,
                                                                       {ones_count, zeros_count} ->
        case Enum.at(diag_value, index) do
          ?1 -> {ones_count + 1, zeros_count}
          ?0 -> {ones_count, zeros_count + 1}
        end
      end)

    if ones_count >= zeros_count do
      ?1
    else
      ?0
    end
  end

  defp find_co2([co2_rating_list], _index) do
    #IO.inspect("Final CO2 Rating: #{co2_rating_list}\n")
    to_string(co2_rating_list) |> String.to_integer(2)
  end

  defp find_co2(diag_report, index) do
    #IO.inspect("CO2 Diag Report: #{inspect(diag_report)} Index: #{index}")
    minority_bit = find_minority_bit(diag_report, index)

    filtered_diag_report =
      Enum.filter(diag_report, fn diag_value ->
        Enum.at(diag_value, index) == minority_bit
      end)

    find_co2(filtered_diag_report, index + 1)
  end

  defp find_minority_bit(diag_report, index) do
    {ones_count, zeros_count} =
      Enum.reduce(diag_report, {_ones_count = 0, _zeros_count = 0}, fn diag_value,
                                                                       {ones_count, zeros_count} ->
        case Enum.at(diag_value, index) do
          ?1 -> {ones_count + 1, zeros_count}
          ?0 -> {ones_count, zeros_count + 1}
        end
      end)

    if zeros_count <= ones_count do
      ?0
    else
      ?1
    end
  end

  # Common functions

  def get_diag_report(input_file \\ "inputs/day03_input.txt") do
    File.read!(input_file)
    |> String.split()
    |> Enum.map(fn bin_num_str -> to_charlist(bin_num_str) end)
  end
end
