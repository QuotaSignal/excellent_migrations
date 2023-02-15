defmodule ExcellentMigrations.MessageGenerator do
  @moduledoc false

  @readme "https://github.com/Artur-Sulej/excellent_migrations"
  @ecto_data_manipulation_message "You're running an operation that may fail using Ecto, are you sure it's safe?"
  @danger_type_info_mapping %{
    check_constraint_added: "#{@readme}#adding-a-check-constraint",
    column_added_with_default: "#{@readme}#adding-a-column-with-a-default-value",
    column_reference_added: "#{@readme}#adding-a-reference",
    column_removed: "#{@readme}#removing-a-column",
    column_renamed: "#{@readme}#renaming-a-column",
    column_type_changed: "#{@readme}#changing-the-type-of-a-column",
    column_volatile_default: "#{@readme}#column-with-volatile-default",
    index_concurrently_without_disable_ddl_transaction:
      "#{@readme}#adding-an-index-concurrently-without-disabling-lock-or-transaction",
    index_concurrently_without_disable_migration_lock:
      "#{@readme}#adding-an-index-concurrently-without-disabling-lock-or-transaction",
    index_not_concurrently: "#{@readme}#adding-an-index-non-concurrently",
    json_column_added: "#{@readme}#adding-a-json-column",
    many_columns_index: "#{@readme}#keeping-non-unique-indexes-to-three-columns-or-less",
    not_null_added: "#{@readme}#setting-not-null-on-an-existing-column",
    operation_delete: @ecto_data_manipulation_message,
    operation_insert: @ecto_data_manipulation_message,
    operation_update: @ecto_data_manipulation_message,
    raw_sql_executed: "#{@readme}#executing-SQL-directly",
    table_dropped: "You're dropping a table here. Make sure you want it gone",
    table_renamed: "#{@readme}#renaming-a-table"
  }

  def build_message(%{type: type, path: path, line: line}) do
    """
    ExcellentMigrations unsafe operation: #{build_message(type)} in #{path}:#{line}
    More information: #{danger_type_mapping(type)}
    """
  end

  def build_message(type) do
    type
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  def danger_type_mapping(type), do: Map.get(@danger_type_info_mapping, type)
end
