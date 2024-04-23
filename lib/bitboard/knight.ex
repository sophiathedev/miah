import Bitwise

defmodule Bitboard.Knight do
  @moduledoc """
  This module is general set-wise bitboard for knight
  """

  alias Bitboard.Utils

  @compile {:inline, knight_attacks: 1}

  @doc "Initialize function for precalculate mask knight attacks"
  @spec initialize_knight_attack() :: list()
  def initialize_knight_attack do
    0..63 |> Stream.map(&Utils.bit_square/1) |> Stream.map(&knight_attacks/1) |> Enum.to_list()
  end

  @doc "Function for get knight attack from bitboard presentation position"
  @spec knight_attacks(non_neg_integer()) :: non_neg_integer()
  def knight_attacks(kn) do
    l1 = band(kn >>> 1, 0x7F7F7F7F7F7F7F7F)
    l2 = band(kn >>> 2, 0x3F3F3F3F3F3F3F3F)
    r1 = band(kn <<< 1, 0xFEFEFEFEFEFEFEFE)
    r2 = band(kn <<< 2, 0xFCFCFCFCFCFCFCFC)
    h1 = bor(l1, r1)
    h2 = bor(l2, r2)

    band(h1 <<< 16 ||| h1 >>> 16 ||| h2 <<< 8 ||| h2 >>> 8, 0xFFFFFFFFFFFFFFFF)
  end
end
