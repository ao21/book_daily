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

  # 読書進捗のパーセンテージを計算
  def self.percentage(max_read_page, total_pages)
    if max_read_page
       100 * max_read_page / total_pages
    else
      0
    end
  end

  # 目標日と総ページ数から1日の目標ページ数を計算
  def self.daily_goal_pages(max_read_page, total_pages, left_days)
    if max_read_page
      ( total_pages - max_read_page ) / left_days
    else
      total_pages / left_days
    end
  end
 
  # 今日の日付から目標日までの残り日数を計算
  def self.left_days(task)
    left_days = (task.finished_on - Date.today).to_i
  end

  # タスク一覧ページ
  # 進捗のデータをハッシュに整形
  def self.progress_data(tasks)
    progress_data = []

    tasks.each do |task|
      max_read_page = task.reads.select(:read_page).maximum(:read_page)
      total_pages = task.book.page_count

      left_days = self.left_days(task)
      percentage = self.percentage(max_read_page, total_pages) || 0
      daily_goal_pages = self.daily_goal_pages(max_read_page, total_pages,left_days) || 0

      progress_data.push(
        {
          left_days: left_days,
          daily_goal_pages: daily_goal_pages,
          percentage: percentage,
        }
      )
    end
    return progress_data
  end
end