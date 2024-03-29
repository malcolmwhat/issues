defmodule Issues.TableFormatter do

  @fields_to_print [
    { "number", :num , "#"},
    { "created_at", :str },
    { "title", :str }
  ]

  @doc """
  Requires a list of maps. It prints the list as a table, with the columns
  normalized based on the longest field entry.
  """
  def print(list) do
    remove_clutter(list)
    |> get_column_widths
    |> print_justified_table(list)
  end


  @doc """
  Helper which returns the first fields of the fields to print list in a list.
  """
  def get_fields_as_strings() do
    Enum.map(@fields_to_print, &(get_field_as_string(&1)))
  end
  def get_field_as_string({ field, _, _ }), do: field
  def get_field_as_string({ field, _ }), do: field


  @doc """
  Helper which returns the display strings of the fields to print list.
  """
  def get_field_display_names() do
    Enum.map(@fields_to_print, &(get_display_string(&1)))
  end
  def get_display_string({ _, _, disp }), do: disp
  def get_display_string({ field, _ }), do: field


  @doc """
  The list we get has a ton of useless data. We get rid of that for ease of
  readability in debugging here. Only the fields in @fields_to_print are kept.
  """
  def remove_clutter(list) do
    Enum.map(list, &(Map.take(&1, get_fields_as_strings)))
  end


  @doc """
  Get the max width required for each column.
  """
  def get_column_widths(list) do
    @fields_to_print
    |> Enum.map(&(max_field_length(&1, list)))  # Get required column widths
  end


  @doc """
  Prints each part of the table, while maintaining the widths for each column.
  """
  def print_justified_table(widths, list) do
    print_header(widths)
    print_delimiting_line(widths)
    Enum.each(list, &(print_line(&1, widths)))
  end


  @doc """
  Prints the @fields_to_prints display names using the widths.
  """
  def print_header(widths) do
    form_header(widths)
    |> Enum.each(&(IO.write(&1)))
  end


  @doc """
  Create the header of the table.
  """
  def form_header(widths) do
    get_field_display_names
    |> Enum.zip(widths)
    |> Enum.map(fn({ str, size }) -> String.ljust(str, size) end)
    |> add_delimeters(" | ")
  end

  defp add_delimeters([]), do: ["\n" | []]
  defp add_delimeters([], _), do: ["\n" | []]
  defp add_delimeters([ head | [] ], _), do: [ head | add_delimeters([])]
  defp add_delimeters([ head | tail ], str) do
    [ head <> str | add_delimeters(tail, str)]
  end


  @doc """
  We need a horizontal line to distinguish the header from the body.
  """
  def print_delimiting_line(widths) do
    widths
    |> Enum.map(&(String.pad_trailing("", &1, "-")))
    |> add_delimeters("-+-")
    |> Enum.each(&(IO.write(&1)))
  end

  defp print_line(line, widths) do
    line
    |> get_line_data
    |> format_line_data(widths)
    |> Enum.each(&(IO.write(&1)))
  end

  defp get_line_data(line) do
    get_fields_as_strings()
    |> Enum.map(&(line[&1]))
    |> Enum.map(&(parse_if_int(&1)))
  end

  defp format_line_data(line, widths) do
    line
    |> Enum.zip(widths)
    |> Enum.map(fn({ str, size }) -> (String.ljust(str, size)) end)
    |> add_delimeters(" | ")
  end

  defp parse_if_int(n) when is_integer(n), do: Integer.to_string(n, 10)
  defp parse_if_int(n), do: n

  defp max_field_length({ field, type, _ }, list) do
    max_field_length({ field, type }, list)
  end

  defp max_field_length({ field, :num }, list) do
    list
    |> Enum.max_by(&(String.length(Integer.to_string(&1[field]))))
    |> Map.get(field)
    |> Integer.to_string(10)  # base 10
    |> String.length
  end

  defp max_field_length({ field, :str }, list) do
    list
    |> Enum.max_by(&(String.length(&1[field])))
    |> Map.get(field)
    |> String.length
  end
end
