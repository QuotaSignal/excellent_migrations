defmodule ExcellentMigrations.DangersDetectorTest do
  use ExUnit.Case
  alias ExcellentMigrations.DangersDetector

  test "detects dangers in AST" do
    {ast, source_code} = get_ast_and_source("20191026103002_execute_raw_sql.exs")

    assert [{:raw_sql_executed, 3}, {:raw_sql_executed, 7}] ==
             DangersDetector.detect_dangers(ast, source_code)
  end

  test "skips dangers with safety assured" do
    {ast, source_code} =
      get_ast_and_source("20191026103004_execute_raw_sql_with_safety_assured.exs")

    assert [] == DangersDetector.detect_dangers(ast, source_code)
  end

  test "skips dangers with safety assured config comments" do
    {ast, source_code} =
      get_ast_and_source("20191026103009_safety_assured_with_config_comments.exs")

    assert [] == DangersDetector.detect_dangers(ast, source_code)
  end

  describe "postgres version-based skipping" do
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

    test "skips column_added_with_default when repo reports PG 11+" do
      Application.put_env(:excellent_migrations, :ecto_repos, [RepoPg11])

      {ast, source_code} =
        get_ast_and_source("20191026103007_add_column_with_default_value.exs")

      assert [] == DangersDetector.detect_dangers(ast, source_code)
    end

    test "detects column_added_with_default when repo reports PG 10" do
      Application.put_env(:excellent_migrations, :ecto_repos, [RepoPg10])

      {ast, source_code} =
        get_ast_and_source("20191026103007_add_column_with_default_value.exs")

      assert [{:column_added_with_default, 4}, {:column_added_with_default, 5}] ==
               DangersDetector.detect_dangers(ast, source_code)
    end

    test "detects column_added_with_default when no ecto_repos configured" do
      Application.delete_env(:excellent_migrations, :ecto_repos)

      {ast, source_code} =
        get_ast_and_source("20191026103007_add_column_with_default_value.exs")

      assert [{:column_added_with_default, 4}, {:column_added_with_default, 5}] ==
               DangersDetector.detect_dangers(ast, source_code)
    end
  end

  defp get_ast_and_source(path) do
    source_code = File.read!("test/example_migrations/#{path}")
    ast = Code.string_to_quoted!(source_code)
    {ast, source_code}
  end
end
