import Bitwise

defmodule Bitboard.String do
  alias Bitboard.Utils

  @spec to_string(non_neg_integer()) :: binary()
  @doc "Function create a board for bitboard for easier in use"
  def to_string(b) do
    y_axis = "  A B C D E F G H"
    board = "8 "
    board <> to_char(b, 63) <> y_axis
  end

  # private function for process of bitboard to_string board generator
  defp to_char(_b, index) when index == -1, do: "\n"
  defp to_char(b, index) do
    char = if band(b, Utils.bit_square(index)) != 0, do: "# ", else: ". "
    seperator = if rem(index, 8) == 0 and index != 0, do: "\n#{div(index, 8)} ", else: ""
    char <> seperator <> to_char(b, index - 1)
  end
end

defmodule Bitboard.Utils do
  @compile { :inline,
    ls1b: 1,
    popcount: 1,
    pop_lsb: 1,
    bit_square: 1,
    next_bit: 1,
    # we doesnt use inline for bit file because it have string operation
    bit_rank: 1,
    bit_not_rank: 1,
  }

  # very important shift function the necessary in every chess engine using bitboard technique
  @spec shift(non_neg_integer(), atom()) :: non_neg_integer()
  def shift(b, direction) do
    (case direction do
      :north -> b <<< 8
      :south -> b >>> 8
      :north_north -> b <<< 16
      :south_south -> b >>> 16
      :east -> band(b, bit_not_file(:h)) >>> 1
      :west -> band(b, bit_not_file(:a)) <<< 1
      :north_east -> band(b, bit_not_file(:h)) <<< 7
      :north_west -> band(b, bit_not_file(:a)) <<< 9
      :south_east -> band(b, bit_not_file(:h)) >>> 9
      :south_west -> band(b, bit_not_file(:a)) >>> 7
      _ -> 0
    end) &&& 0xffffffffffffffff # and operation with full board mask for guarantee that after shift the bit already on the board
  end

  @doc "This function perform all shift in shift function in one operation"
  @spec all_shift(non_neg_integer()) :: non_neg_integer()
  def all_shift(x) do
    all_direction = [:north, :south, :east, :west, :north_west, :north_east, :south_east, :south_west]
    all_shift = all_direction |> Stream.map(fn(dir) -> shift(x, dir) end) |> Enum.reduce(0, &(bor(&1, &2)))
    all_shift
  end

  @doc "Shift to next bit"
  @spec next_bit(non_neg_integer()) :: non_neg_integer()
  def next_bit(b), do: b >>> 1

  # population count routine function
  # https://www.chessprogramming.org/Population_Count#The_PopCount_routine
  @doc "Population Count for count every 1-bit in a Integer"
  @spec popcount(integer()) :: byte()
  def popcount(x) do
    k1 = 0x5555555555555555
    k2 = 0x3333333333333333
    k4 = 0x0f0f0f0f0f0f0f0f
    kf = 0x0101010101010101

    x = x - band(x >>> 1, k1)
    x = band(x, k2) + band(x >>> 2, k2)
    x = band(x + (x >>> 4), k4)
    x = (x * kf) >>> 56
    band(x, 0x3f)
  end # popcount/1

  # use debruijn64 for get least significant bit index
  @doc "Get index of least significant bit in a Integer using Debruijn64 algorithm"
  @spec ls1b(integer()) :: any()
  def ls1b(x) when x != 0 do
    index64 = [ 0,  1, 48,  2, 57, 49, 28,  3, 61, 58, 50, 42, 38, 29, 17,  4, 62, 55, 59, 36, 53, 51, 43, 22, 45, 39, 33, 30, 24, 18, 12,  5, 63, 47, 56, 27, 60, 41, 37, 16, 54, 35, 52, 21, 44, 32, 23, 11, 46, 26, 40, 15, 34, 20, 31, 10, 25, 14, 19,  9, 13,  8,  7,  6 ]
    debruijn64 = 0x03f79d71b4cb0a89
    idx = band(((band(x, -x) * debruijn64) >>> 58), 0x3f)
    index64 |> Enum.at(idx)
  end # ls1b/1

  # pop least significant bit using bitwise and operation with x - 1
  @doc "Pop least significant bit"
  @spec pop_lsb(integer()) :: integer()
  def pop_lsb(x), do: band(x, x - 1) # pop_lsb/1

  # function for board operation
  @doc "Get the square present in Bitboard"
  @spec bit_square(integer()) :: non_neg_integer()
  def bit_square(x), do: band(1 <<< x, 0xffffffffffffffff)

  # function for get the file as the bitboard presentation
  @doc "Get the file of the board using Bitboard presentation"
  @spec bit_file(atom()) :: non_neg_integer()
  def bit_file(file) do
    # tricky get the ascii code using pattern matching of elixir
    char = file |> to_string()
    <<ascii::utf8>> = char

    required_shift = ascii - 97
    0x8080808080808080 >>> required_shift
  end

  # function for get the rank as the bitboard presentation
  @doc "Get the rank of the board using Bitboard presentation"
  @spec bit_rank(non_neg_integer()) :: non_neg_integer()
  def bit_rank(rank), do: (0xff <<< (8 * rank))

  # reverse the file is not_file = ~file
  @doc "Reverse the file from original file bitboard"
  @spec bit_not_file(atom()) :: non_neg_integer()
  def bit_not_file(file), do: band(bnot(bit_file(file)), 0xffffffffffffffff)

  # reverse the rank is not_rank = ~rank
  @doc "Reverse the rank from original rank bitboard"
  @spec bit_not_rank(non_neg_integer()) :: non_neg_integer()
  def bit_not_rank(rank), do: band(bnot(bit_rank(rank)), 0xffffffffffffffff)
end
