defmodule HtmlEntities.Util do
  @moduledoc """
  Utility functions for managing metadata.

  Putting this code here makes it testable, and allows the code
  generation part of HtmlEntities to be as small as possible.
  """

  @type entity :: {String.t, String.t, String.t}

  @doc "Load HTML entities from an external file."
  @spec load_entities(String.t) :: [entity]
  def load_entities(filename) do
    File.stream!(filename) |> convert_lines_to_entities
  end

  @spec load_json_entities(String.t) :: [entity]
  def load_json_entities(filename) do
    File.read!("lib/html_entities_list_decode.txt") |> Poison.Parser.parse!
      |> Enum.map(fn({k, x}) ->
          {
            k |> String.trim_leading("&") |> String.trim_trailing(";"),
            x["characters"],
            x["codepoints"] |> List.first
          }
         end)
  end

  @doc "Convert a list of comma-separated lines to entity definitions."
  @spec convert_lines_to_entities([String.t] | File.Stream.t) :: [{String.t, String.t, String.t}]
  def convert_lines_to_entities(lines) do
    Enum.reduce(lines, [], &add_entity_to_list/2)
  end

  defp add_entity_to_list(line, list) do
    [name, character, codepoint] = line |> String.rstrip |> String.split(",")
    :lists.keystore(name, 1, list, {name, character, codepoint})
  end
end
