defmodule Mal.Reader do
  def read_str(input) do
    tokenize(input) |> read_form() |> elem(0)
  end

  defp tokenize(input) do
    regex = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"?|;.*|[^\s\[\]{}('"`,;)]*)/

    Regex.scan(regex, input, capture: :all_but_first)
    |> List.flatten()
    # Remove the last match, which is an empty string
    |> List.delete_at(-1)

    # |> Enum.filter(fn token -> not String.starts_with?(token, ";") end)
  end

  defp read_form([next | rest]) do
    case next do
      "(" -> read_list(rest, [])
      ")" -> {{:mal_error, "unexpected )"}, []}
      "[" -> read_vector(rest, [])
      "]" -> {{:mal_error, "unexpected ]"}, []}
      "{" -> read_hash_map(rest, [])
      "}" -> {{:mal_error, "unexpected }"}, []}
      _ -> {read_atom(next), rest}
    end
  end

  defp read_list(tokens, acc) do
    read_seq(tokens, acc, :mal_list, ")")
  end

  defp read_vector(tokens, acc) do
    read_seq(tokens, acc, :mal_vector, "]")
  end

  defp read_hash_map(tokens, acc) do
    read_seq(tokens, acc, :mal_hash_map, "}")
  end

  defp read_seq([], _acc, _ttype, end_seq), do: {{:mal_error, "expected #{end_seq}, got EOF"}, []}

  defp read_seq([head | rest] = tokens, acc, ttype, end_seq) do
    cond do
      String.ends_with?(head, end_seq) ->
        {{ttype, Enum.reverse(acc)}, rest}

      true ->
        {token, rest} = read_form(tokens)
        read_seq(rest, [token | acc], ttype, end_seq)
    end
  end

  defp read_atom("nil"), do: nil
  defp read_atom("true"), do: true
  defp read_atom("false"), do: false
  defp read_atom(":" <> rest), do: {:mal_keyword, String.to_atom(rest)}
  defp read_atom(token) do
    cond do

      String.match?(token, ~r/^"(?:\\.|[^\\"])*"$/) ->
      token |> Code.string_to_quoted
                |> elem(1)

      String.starts_with?(token, "\"") ->
        {:mal_error, "expected '\"', got EOF"}

      Regex.match?(~r/^-?[0-9]+$/, token) ->
        String.to_integer(token, 10)

      true ->
        {:symbol, token}
    end
  end
end
