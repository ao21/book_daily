class RenameGoalDateColumnToTasks < ActiveRecord::Migration[6.1]
  def change
    rename_column :tasks, :goal_date, :finished_on
  end
end
