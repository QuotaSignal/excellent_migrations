defmodule ExcellentMigrations.PostgresVersionTest do
  use ExUnit.Case
  alias ExcellentMigrations.PostgresVersion

  setup do
    original = Application.get_env(:excellent_migrations, :ecto_repos)

    on_exit(fn ->
      if original do
        Application.put_env(:excellent_migrations, :ecto_repos, original)
      else
        Application.delete_env(:excellent_migrations, :ecto_repos)
      end
    end)
  end

  test "returns empty list when no ecto_repos configured" do
    Application.delete_env(:excellent_migrations, :ecto_repos)
    assert PostgresVersion.safe_skips() == []
  end

  test "returns empty list when repo does not implement min_pg_version" do
    Application.put_env(:excellent_migrations, :ecto_repos, [RepoWithoutVersion])
    assert PostgresVersion.safe_skips() == []
  end

  test "skips column_added_with_default for PG 11+" do
    Application.put_env(:excellent_migrations, :ecto_repos, [RepoPg11])
    assert :column_added_with_default in PostgresVersion.safe_skips()
  end

  test "does not skip column_added_with_default for PG 10" do
    Application.put_env(:excellent_migrations, :ecto_repos, [RepoPg10])
    refute :column_added_with_default in PostgresVersion.safe_skips()
  end

  test "uses first repo that implements min_pg_version" do
    Application.put_env(:excellent_migrations, :ecto_repos, [RepoWithoutVersion, RepoPg11])
    assert :column_added_with_default in PostgresVersion.safe_skips()
  end
end

defmodule RepoWithoutVersion do
end

defmodule RepoPg11 do
  def min_pg_version, do: %{major: 11, minor: 0, patch: 0}
end

defmodule RepoPg10 do
  def min_pg_version, do: %{major: 10, minor: 5, patch: 0}
end
