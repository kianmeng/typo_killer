defmodule TypoKiller.Finder do
  @moduledoc """
  Find typos
  """
  @minimum_jaro_distance 0.95

  @doc """
  Based on a list of words, search for possible typos by comparing them with an auxiliar dictionary
  """
  @spec find_typos({words :: MapSet.t(), dictionary :: MapSet.t()}) :: MapSet.t()

  def find_typos({words, dictionary}) do
    words
    |> Flow.from_enumerable()
    |> Flow.map(fn word -> calculate_distance(word, dictionary) end)
    |> Flow.reduce(fn -> MapSet.new() end, fn a, b -> MapSet.union(MapSet.new(a), b) end)
    |> MapSet.new()
    |> MapSet.delete(nil)
  end

  @spec calculate_distance(word :: String.t(), dict :: list(String.t())) :: list(String.t() | nil)
  defp calculate_distance(word, dict) do
    dict
    |> Enum.map(fn word_from_dict ->
      with jaro_distance <- String.jaro_distance(word, word_from_dict),
           true <- jaro_distance >= @minimum_jaro_distance and jaro_distance < 1.0 do
        word
      else
        false -> nil
      end
    end)
  end
end
