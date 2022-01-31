class Task < ApplicationRecord
  belongs_to :book
  belongs_to :user
  has_many :reads, dependent: :destroy

  # バリデーション
  validates :started_on, presence: true
  validates :finished_on, presence: true
  validate :validate_finished_on

  def validate_finished_on
    if finished_on.present? && finished_on < started_on
      errors.add(:finished_on, ": 開始日より前の日付は使えません")
    end
  end

  # 進行中のタスク一覧(TaskTodayページ)
  def self.tasks_in_progress(tasks)
    tasks_in_progress = []
    max_reads = Task.includes(:reads).group(:task_id).maximum(:up_to_page)
    tasks.each do |task|
      max_reads[task.id].present? ? max_page = max_reads[task.id] : max_page = 0
      total_pages = task.book.total_pages
      if total_pages > max_page
        tasks_in_progress.push(task)
      end
    end
    return tasks_in_progress
  end

  # 残りページ数、今日の最大ページ数、最大ページ数
  def self.task_data(task)
    max_page_yesterday = task.reads.where("read_on < ?", Date.today).maximum(:up_to_page) || 0
    max_page_today = task.reads.where("read_on = ?", Date.today).maximum(:up_to_page) || 0
    max_page = [max_page_yesterday, max_page_today].max
    read_pages = task.book.total_pages - max_page_yesterday

    task_data = {
      read_pages: read_pages,
      max_page_today: max_page_today,
      max_page: max_page
    }
  end

  # 今日の目標ページ番号( 残りページ数/残り日数 )
  def self.today_goal_page(task, task_data)
    left_days = (task.finished_on - Date.today + 1).to_i
    left_days <= 0? left_days=0 : left_days
    left_days == 0? task_data[:read_pages] : (task_data[:read_pages] / left_days.to_f).ceil
  end

  # 今週の進捗登録がある日とない日
  def self.status_week(task)
    today = Date.today
    from = today.prev_occurring(:monday)
    to = today.next_occurring(:sunday)
    if today.wday == 1
      from = today
    elsif today.wday == 0
      to = today
    end

    reads = task.reads.select(:read_on).where(read_on: from..to)

    status_week = {}
    (from..to).each do |date|
      reads_date = reads.select{ |read|read.read_on == date}
      if reads_date.present?
        per = "--main"
      else
        per = nil
      end
      status_week.store(date.day, per)
    end
    return status_week
  end

  # 今日の目標のデータ(TaskTodayページ)
  def self.today_data(task)
    task_data = self.task_data(task)
    today_goal_page = self.today_goal_page(task, task_data)
    status_week = self.status_week(task)

    # 今日の目標達成ステータス
    if today_goal_page <= task_data[:max_page_today]
      status = { color: "main", status: "DONE"}
    else
      today_left_pages = today_goal_page - task_data[:max_page]
      status = { color: "second", status: "あと#{today_left_pages}ページ"}
    end

    today_data = {
      today_goal_page: today_goal_page,
      status: status,
      status_week: status_week
    }
    return today_data
  end

  # タスク進捗パーセンテージの計算
  def self.cal_percentage(task_percentage, max_page, total_pages)
    percentage = 100 * max_page / total_pages

    task_percentage.push(
      {
        read: percentage, unread: 100 - percentage
      }
    )
  end

  # タスクの進捗パーセンテージ(TaskIndaxページ)
  def self.tasks_percentage(tasks)
    tasks_percentage = []
    max_reads = Task.includes(:reads).group(:task_id).maximum(:up_to_page)

    tasks.each do |task|
      max_reads[task.id].present? ? max_page = max_reads[task.id] : max_page = 0
      total_pages = task.book.total_pages
      self.cal_percentage(tasks_percentage, max_page, total_pages)
    end
    return tasks_percentage
  end

  # タスク個別の進捗パーセンテージ(TaskShowページ)
  def self.task_percentage(task)
    task_percentage = []
    max_page = task.reads.select(:up_to_page).maximum(:up_to_page) || 0
    total_pages = task.book.total_pages
    self.cal_percentage(task_percentage, max_page, total_pages)
    return task_percentage
  end
end