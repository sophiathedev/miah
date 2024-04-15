import Bitwise

defmodule Bitboard.Utils do
  @compile { :inline,
    ls1b: 1,
    popcount: 1,
    pop_lsb: 1,
    bit_square: 1,
    # we doesnt use inline for bit file because it have string operation
    bit_rank: 1,
    bit_not_rank: 1,
  }

  # population count routine function
  # https://www.chessprogramming.org/Population_Count#The_PopCount_routine
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
  @spec ls1b(integer()) :: any()
  def ls1b(x) when x != 0 do
    index64 = [ 0,  1, 48,  2, 57, 49, 28,  3, 61, 58, 50, 42, 38, 29, 17,  4, 62, 55, 59, 36, 53, 51, 43, 22, 45, 39, 33, 30, 24, 18, 12,  5, 63, 47, 56, 27, 60, 41, 37, 16, 54, 35, 52, 21, 44, 32, 23, 11, 46, 26, 40, 15, 34, 20, 31, 10, 25, 14, 19,  9, 13,  8,  7,  6 ]
    debruijn64 = 0x03f79d71b4cb0a89
    idx = band(((band(x, -x) * debruijn64) >>> 58), 0x3f)
    index64 |> Enum.at(idx)
  end # ls1b/1

  # pop least significant bit using bitwise and operation with x - 1
  @spec pop_lsb(integer()) :: integer()
  def pop_lsb(x), do: band(x, x - 1) # pop_lsb/1

  # function for board operation
  @spec bit_square(integer()) :: non_neg_integer()
  def bit_square(x), do: band(1 <<< x, 0xffffffffffffffff)

  # function for get the file as the bitboard presentation
  @spec bit_file(atom()) :: non_neg_integer()
  def bit_file(file) do
    # tricky get the ascii code using pattern matching of elixir
    char = file |> to_string()
    <<ascii::utf8>> = char

    required_shift = ascii - 97
    0x8080808080808080 >>> required_shift
  end

  # function for get the rank as the bitboard presentation
  @spec bit_rank(non_neg_integer()) :: non_neg_integer()
  def bit_rank(rank), do: (0xff <<< (8 * rank))

  # reverse the file is not_file = ~file
  @spec bit_not_file(atom()) :: non_neg_integer()
  def bit_not_file(file), do: band(bnot(bit_file(file)), 0xffffffffffffffff)

  # reverse the rank is not_rank = ~rank
  @spec bit_not_rank(non_neg_integer()) :: non_neg_integer()
  def bit_not_rank(rank), do: band(bnot(bit_rank(rank)), 0xffffffffffffffff)

end
