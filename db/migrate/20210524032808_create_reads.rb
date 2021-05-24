class CreateReads < ActiveRecord::Migration[6.1]
  def change
    create_table :reads do |t|
      t.date :read_on, null: false
      t.integer :read_page, null: false
      t.references :task, null: false, foreign_key: true

      t.timestamps
    end
  end
end
