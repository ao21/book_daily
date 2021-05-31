class Task < ApplicationRecord
  belongs_to :book
  belongs_to :user
  has_many :reads, dependent: :destroy

  with_options presence: true do
    validates :started_on
    validates :finished_on
  end
  validate :finished_on_cannot_be_before_started_on

  def finished_on_cannot_be_before_started_on
    if finished_on.present? && finished_on < started_on
      errors.add(:finished_on, ": 開始日より前の日付は使えません")
    end
  end

  # 進捗のデータをハッシュに整形
  def self.progress_data(task)
    max_read_page = task.reads.select(:read_page).maximum(:read_page)
    total_pages = task.book.page_count

    left_days = (task.finished_on - Date.today).to_i
    daily_goal_pages = ( total_pages - max_read_page ) / left_days
    percentage = 100 * max_read_page / total_pages

    progress_data = {
      left_days: left_days,
      daily_goal_pages: daily_goal_pages,
      percentage: percentage,
    }
  end
end