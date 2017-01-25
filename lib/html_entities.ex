defmodule HtmlEntities do
  @moduledoc """
  Decode and encode HTML entities in a string.

  ## Examples

  Decoding:

      iex> "Tom &amp; Jerry" |> HtmlEntities.decode
      "Tom & Jerry"
      iex> "&#161;Ay, caramba!" |> HtmlEntities.decode
      "¡Ay, caramba!"
      iex> "&#337; &#x151;" |> HtmlEntities.decode
      "ő ő"

  Encoding:

      iex> "Tom & Jerry" |> HtmlEntities.encode
      "Tom &amp; Jerry"
      iex> "<< KAPOW!! >>" |> HtmlEntities.encode
      "&lt;&lt; KAPOW!! &gt;&gt;"
  """

  @decode_external_resource "lib/html_entities_list_decode.txt"
  @encode_external_resource "lib/html_entities_list_encode.txt"

  @doc "Decode HTML entities in a string."
  @spec decode(String.t) :: String.t
  def decode(string) do
    Regex.replace(~r/\&([^\s][0-9][0-9]?[0-9]?[0-9]?)/, string, &replace_entity/2)
  end

  @doc "Encode HTML entities in a string."
  @spec encode(String.t) :: String.t
  def encode(string) do
    String.graphemes(string)
    |> Enum.map(&replace_character/1)
    |> Enum.join()
  end

  decode_codes = HtmlEntities.Util.load_entities(@decode_external_resource)

  for {name, character, codepoint} <- decode_codes do
    defp replace_entity(_, unquote(name)), do: unquote(character)
    defp replace_entity(_, unquote(codepoint)), do: unquote(character)
  end

  defp replace_entity(original, "#x" <> code) do
    try do
      << String.to_integer(code, 16) :: utf8 >>
    rescue ArgumentError -> original end
  end

  defp replace_entity(original, "#" <> code) do
    try do
      << String.to_integer(code) :: utf8 >>
    rescue ArgumentError -> original end
  end

  defp replace_entity(original, _), do: original

  encode_codes = HtmlEntities.Util.load_entities(@encode_external_resource)

  for {name, character, codepoint} <- encode_codes do
    defp replace_character(unquote(character)), do: unquote("&" <> name <> ";")
  end

  defp replace_character(original), do: original
end
