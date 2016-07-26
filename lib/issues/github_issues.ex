defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Elixir malcolm.watt@mail.mcgill.ca"} ]

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({ :ok, %{status_code: 200, body: body}}) do
    { :ok,    body }
  end

  def handle_response({ :error, %{id: _, reason: reason}}) do
    { :error, reason }
  end
end
