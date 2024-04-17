#import Bitwise
import Bitboard.Utils

defmodule Bitboard.King do
  @doc "Initialize function for precalculate mask king attack"
  @spec initialize_king_attack() :: list(non_neg_integer())
  def initialize_king_attack do
    mask = 0..63 |> Enum.map(fn(pos) -> all_shift(bit_square(pos)) end) |> Enum.to_list
    mask
  end
end
