import Bitwise

defmodule Bitboard.Pawn do
  @moduledoc """
  This module is general set-wise for pawn mask, evaluation, attacks
  """

  alias Bitboard.Utils

  @compile {:inline,
            single_push_target: 3, double_push_target: 3, east_attacks: 2, west_attacks: 2}

  @rank4 Utils.bit_rank(4)
  @rank5 Utils.bit_rank(5)

  # General set-wise pawn operation

  @doc "Mask for single pawn push"
  @spec single_push_target(non_neg_integer(), non_neg_integer(), :black | :white) ::
          non_neg_integer()
  def single_push_target(pawns, empty, :white), do: band(Utils.shift(pawns, :north), empty)
  def single_push_target(pawns, empty, :black), do: band(Utils.shift(pawns, :south), empty)

  @doc "Mask for double pawn push"
  @spec double_push_target(non_neg_integer(), non_neg_integer(), :black | :white) ::
          non_neg_integer()
  def double_push_target(pawns, empty, :white) do
    single_push = single_push_target(pawns, empty, :white)
    Utils.shift(single_push, :north) &&& empty &&& @rank4
  end

  def double_push_target(pawns, empty, :black) do
    single_push = single_push_target(pawns, empty, :black)
    Utils.shift(single_push, :south) &&& empty &&& @rank5
  end

  # Get the mask pawn attacks
  @doc "Generate all squares that are attacked by pawns of a color at East direction"
  @spec east_attacks(non_neg_integer(), :black | :white) :: non_neg_integer()
  def east_attacks(pawns, :white), do: Utils.shift(pawns, :north_east)
  def east_attacks(pawns, :black), do: Utils.shift(pawns, :south_east)

  @doc "Generate all squares that are attacked by pawns of a color at West direction"
  @spec west_attacks(non_neg_integer(), :black | :white) :: non_neg_integer()
  def west_attacks(pawns, :white), do: Utils.shift(pawns, :north_west)
  def west_attacks(pawns, :black), do: Utils.shift(pawns, :south_west)

  # a bit-wise boolean instruction to combine those disjoint sets
  @spec pawn_any_attacks(non_neg_integer(), :black | :white) :: non_neg_integer()
  def pawn_any_attacks(pawns, color),
    do: bor(east_attacks(pawns, color), west_attacks(pawns, color))

  @spec pawn_dbl_attacks(non_neg_integer(), :black | :white) :: non_neg_integer()
  def pawn_dbl_attacks(pawns, color),
    do: band(east_attacks(pawns, color), west_attacks(pawns, color))

  @spec pawn_single_attacks(non_neg_integer(), :black | :white) :: non_neg_integer()
  def pawn_single_attacks(pawns, color),
    do: bxor(east_attacks(pawns, color), west_attacks(pawns, color))
end
