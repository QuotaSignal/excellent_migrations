defmodule ExcellentMigrations.PostgresVersion do
  @moduledoc """
  Determines which danger types can be skipped based on the minimum PostgreSQL
  version reported by the configured repo.

  Configure via:

      config :excellent_migrations, ecto_repos: [MyApp.Repo]

  The first repo in the list that exports `min_pg_version/0` will be used.
  That function should return a map like `%{major: 15, minor: 0, patch: 0}`.
  """

  @version_safe_checks [
    {:column_added_with_default, {11, 0, 0}}
  ]

  @spec safe_skips() :: [atom()]
  def safe_skips do
    case get_min_pg_version() do
      nil -> []
      version -> skips_for_version(version)
    end
  end

  defp get_min_pg_version do
    :excellent_migrations
    |> Application.get_env(:ecto_repos, [])
    |> Enum.find_value(fn repo ->
      if function_exported?(repo, :min_pg_version, 0), do: repo.min_pg_version()
    end)
  end

  defp skips_for_version(%{major: major, minor: minor, patch: patch}) do
    for {danger_type, min_version} <- @version_safe_checks,
        {major, minor, patch} >= min_version do
      danger_type
    end
  end
end
