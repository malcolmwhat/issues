defmodule Issues.CLI do

  @default_count 4

  @moduledoc """
  Handle command line parsing and calling of other functions that generate
  a table of the last `n` issues in a github project.
  """

  def run(argv) do
    parse_args(argv)
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
      -> { user, project, count }

    { _, [ user, project ], _ }
      -> { user, project, @default_count }

    _ -> :help
    end
  end
end
