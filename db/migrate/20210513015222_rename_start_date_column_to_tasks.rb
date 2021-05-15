class RenameStartDateColumnToTasks < ActiveRecord::Migration[6.1]
  def change
    rename_column :tasks, :start_date, :started_on
  end
end
