class RenameReadPageColumnToReads < ActiveRecord::Migration[6.1]
  def change
    rename_column :reads, :read_page, :up_to_page
  end
end
