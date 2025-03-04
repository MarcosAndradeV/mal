defmodule Mal.Printer do
  def pr_str(ast, print_readably \\ true)
  def pr_str(ast, true) when is_bitstring(ast), do: inspect(ast)
  def pr_str(ast, false) when is_bitstring(ast), do: ast

  def pr_str(ast, _) do
    case ast do
      {:mal_list, list} -> "(#{Enum.map_join(list, " ", &pr_str(&1))})"
      {:mal_vector, list} -> "[#{Enum.map_join(list, " ", &pr_str(&1))}]"
      {:mal_hash_map, list} -> "{#{Enum.map_join(list, " ", &pr_str(&1))}}"
      {:mal_keyword, kw} -> ":#{kw}"
      {:mal_function, _f} -> "#<function>"
      {:mal_error, reason} -> reason
      {:symbol, sym} -> sym
      nil -> "nil"
      val -> to_string(val)
    end
  end
end
