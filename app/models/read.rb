class Read < ApplicationRecord
  belongs_to :task
  has_one :user, through: :task

  with_options presence: true do
    validates :read_on
    validates :up_to_page, numericality: { only_integer: true }
  end

  # タスク一覧ページの SimpleCalendar で使用
  def start_time
    self.read_on
  end

  # タスク一覧ページのサイドバーの今月、先月の読書データ
  def self.month_data(user)
    max_pages = user.reads.where(read_on: Time.now.all_month).group(:task_id).maximum(:up_to_page)
    min_pages = user.reads.where(read_on: Time.now.all_month).group(:task_id).minimum(:up_to_page)
    min_last = user.reads.where(read_on: Time.now.last_month.all_month).group(:task_id).maximum(:up_to_page)
    this_month = self.month_data_cal(max_pages, min_pages, min_last)

    max_pages = min_last
    min_pages = user.reads.where(read_on: Time.now.last_month.all_month).group(:task_id).minimum(:up_to_page)
    min_last = user.reads.where(read_on: 2.months.ago.all_month).group(:task_id).maximum(:up_to_page)
    last_month = self.month_data_cal(max_pages, min_pages, min_last)

    month_data = {
      this_month: this_month,
      last_month: last_month
    }
  end

  # 読書量の計算式
  def self.month_data_cal(max_pages, min_pages, min_last)
    results = []
    month_book = 0

    tasks = Task.find(max_pages.keys)

    max_pages.each do |task_id, value|
      # 今月の読んだページ数、1日のページ数を計算
      if max_pages[task_id] == min_pages[task_id]
        if min_last[task_id].present?
          min_page = min_last[task_id]
        else
          min_page = 0
        end
      else
        min_page = min_pages[task_id]
      end
      result = value - min_page
      results << result

      # 今月の読んだ冊数を計算
      tasks.each do |task|
        if value == task.book.total_pages
          month_book = 1
        else
          month_book = 0
        end
        month_book += month_book
      end
    end

    month_page = results.sum
    month_days = [*Date.today.all_month].size
    day_page = month_page / month_days

    # ハッシュに整形
    month_data_cal = {
      month_page: month_page,
      day_page: day_page,
      month_book: month_book
    }
  end
end
