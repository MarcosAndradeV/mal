defmodule Mal.Core do
  def namespace do
    %{
      "+" => fn [a, b] -> a + b end,
      "-" => fn [a, b] -> a - b end,
      "*" => fn [a, b] -> a * b end,
      "/" => fn [a, b] -> div(a, b) end,
      ">" => fn [a, b] -> a > b end,
      "<" => fn [a, b] -> a < b end,
      "<=" => fn [a, b] -> a <= b end,
      ">=" => fn [a, b] -> a >= b end,
      "=" => &eq/1,
      "prn" => &prn/1,
      "println" => &prn/1,
      "pr-str" => &pr_str/1,
      "str" => &str/1,
      "list" => &list/1,
      "list?" => &list?/1,
      "empty?" => &empty?/1,
      "count" => &count/1
    }
    |> convert()
  end

  defp convert_vector({t, ast}) when t in [:mal_list, :mal_vector] do
    new_ast = Enum.map(ast, &convert_vector/1)
    {:mal_list, new_ast}
  end

  defp convert_vector(other), do: other

  defp eq([a, b]) do
    convert_vector(a) == convert_vector(b)
  end

  def pr_str(ast) do
    Enum.map_join(ast, " ", &Mal.Printer.pr_str/1)
  end

  def prn(ast) do
    ast
    |> Enum.map(&Mal.Printer.pr_str/1)
    |> Enum.join(" ")
    |> IO.puts()

    nil
  end

  def str(ast) do
    Enum.map_join(ast, "", &(Mal.Printer.pr_str(&1, false)))
  end

  def list(ast) do
    {:mal_list, ast}
  end

  def list?([{:mal_list, _}]), do: true
  def list?(_), do: false

  def empty?([{t, []}]) when t in [:mal_list, :mal_vector], do: true
  def empty?(_), do: false
  def count([{t, a}]) when t in [:mal_list, :mal_vector], do: length(a)
  def count(_), do: 0

  defp convert(map) do
    for {name, func} <- map, into: %{} do
      {name, {:mal_function, func}}
    end
  end
end
