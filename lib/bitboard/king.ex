defmodule Bitboard.King do
  @moduledoc """
  This module is general set-wise for king, attacks, move and evaluation
  """

  alias Bitboard.Utils

  @doc "Initialize function for precalculate mask king attack"
  @spec initialize_king_attack() :: list(non_neg_integer())
  def initialize_king_attack do
    0..63 |> Stream.map(&Utils.bit_square/1) |> Stream.map(&Utils.all_shift/1) |> Enum.to_list
  end
end
