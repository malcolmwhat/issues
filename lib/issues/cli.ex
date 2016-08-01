defmodule Issues.CLI do

  @default_count 4

  @moduledoc """
  Handle command line parsing and calling of other functions that generate
  a table of the last `n` issues in a github project.
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
   `argv` can be -h or --help, which returns :help.

  Otherwise it is a github username, project name, and optionally the number of
  entries to get and format.

  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, swicthes: [ help: :boolean ],
                                     aliases:  [ h:    :help   ])

    case parse do
    { [ help: true ], _, _ }
      -> :help

    { _, [ user, project, count ], _}
      -> { user, project, String.to_integer(count) }

    { _, [ user, project ], _ }
      -> { user, project, @default_count }

    _ -> :help
    end
  end

  @doc """
  Process the parsed arguments. If we have :help, then we print help for the
  user, if we have a valid tuple, then we fetch the issues from github.
  """
  def process(:help) do
    IO.puts """
    usage:   issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end
  def process({ user, project, count }) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> convert_to_list_of_maps
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> Issues.TableFormatter.print
  end

  def decode_response({ :ok, body }), do: body

  def decode_response({ :error, error }) do
    { _, message } = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def convert_to_list_of_maps(list) do
    list
    |> Enum.map(&Enum.into(&1, Map.new))
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort(list_of_issues, &(&1["created_at"] <= &2["created_at"]))
  end
end
