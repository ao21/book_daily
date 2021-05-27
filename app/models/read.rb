class Read < ApplicationRecord
  belongs_to :task

  validates: read_on, presence: true
  validates: read_page, presence: true, numericality: { only_integer: true }
  validates: task_id, presence: true
end
