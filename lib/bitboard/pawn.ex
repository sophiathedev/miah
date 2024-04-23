import Bitwise

defmodule Bitboard.Pawn do
  alias Bitboard.Utils

  @compile {:inline, single_push_target: 3, double_push_target: 3}

  @rank4 Utils.bit_rank(4)
  @rank5 Utils.bit_rank(5)

  @doc "Mask for single pawn push"
  @spec single_push_target(:black | :white, non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def single_push_target(:white, pawns, empty) do
    band(Utils.shift(pawns, :north), empty)
  end

  def single_push_target(:black, pawns, empty) do
    band(Utils.shift(pawns, :south), empty)
  end

  @doc "Mask for double pawn push"
  @spec double_push_target(:black | :white, non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def double_push_target(:white, pawns, empty) do
    single_push = single_push_target(:white, pawns, empty)
    Utils.shift(single_push, :north) &&& empty &&& @rank4
  end

  def double_push_target(:black, pawns, empty) do
    single_push = single_push_target(:black, pawns, empty)
    Utils.shift(single_push, :south) &&& empty &&& @rank5
  end
end
