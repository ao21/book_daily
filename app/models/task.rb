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

  def self.array_tasks_in_progress(user)
    array_tasks_in_progress = []
    tasks = user.tasks
    tasks.each do |task|
      book_total_pages = task.book.total_pages
      max_read_up_to_page = task.reads.select(:up_to_page).maximum(:up_to_page) || 0
      if book_total_pages > max_read_up_to_page
        array_tasks_in_progress.push(task)
      end
    end
    return array_tasks_in_progress
  end

  def self.calculate_days_left_until_finished_on(task)
    days_left_until_finished_on = (task.finished_on - Date.today + 1).to_i
    if days_left_until_finished_on < 0
      days_left_until_finished_on = 0
    else
      days_left_until_finished_on
    end
  end


  def self.decide_status_todays_target(task)
    max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
      # "Read".constantize で Read が Rails のモジュールだと判断されないようにしている
    days_left_until_finished_on = self.calculate_days_left_until_finished_on(task)

    if days_left_until_finished_on == 0
      target_pages_per_a_day = task.book.total_pages - max_read_up_to_page_until_yesterday
    else
      target_pages_per_a_day = ((task.book.total_pages - max_read_up_to_page_until_yesterday) / days_left_until_finished_on.to_f).ceil
    end

    todays_target_up_to_page = target_pages_per_a_day + max_read_up_to_page_until_yesterday
    max_read_up_to_page_today = "Read".constantize.where(task_id: task.id).where("read_on = ?", Date.today).maximum(:up_to_page) || 0

    # ステータスを決める
    if todays_target_up_to_page <= max_read_up_to_page_today
      return "DONE"
    else
      pages_left_to_todays_target = todays_target_up_to_page - max_read_up_to_page_today
      return "あと#{pages_left_to_todays_target}ページ"
    end
  end


  # 読書進捗のパーセンテージを計算
  def self.percentage(max_read_up_to_page, total_pages)
    if max_read_up_to_page
       100 * max_read_up_to_page / total_pages
    else
      0
    end
  end

  # 残り日数を計算
  def self.left_days(task)
    left_days = (task.finished_on - Date.today).to_i
    if left_days < 0
      left_days = 0
    else
      left_days
    end
  end

  # 目標日と総ページ数から1日の目標ページ数を計算
  def self.daily_pages_by_left_days(task, max_read_up_to_page, total_pages)
    left_days = self.left_days(task)

    if left_days == 0
      total_pages - max_read_up_to_page
    elsif max_read_up_to_page
      ( total_pages - max_read_up_to_page ) / left_days
    else
      total_pages / left_days
    end
  end

  def self.daily_goal_pages(task, max_read_up_to_page, total_pages)
    new_read = task.reads.order(up_to_page: :desc).limit(2)
    if new_read.present?
      daily_goal_pages = self.daily_pages_by_left_days(task, max_read_up_to_page, total_pages)
      if new_read[0].read_on == Date.today
        daily_goal_pages - new_read[1].up_to_page
      else
        daily_goal_pages
      end
    else
      0
    end
  end

  def self.today_page_number(task, max_read_up_to_page, total_pages)
    daily_goal_pages = self.daily_goal_pages(task, max_read_up_to_page, total_pages)
    max_read_up_to_page + daily_goal_pages
  end

  # 進捗データを計算
  def self.cul_progress_data(task, progress_data)
    max_read_up_to_page = task.reads.select(:up_to_page).maximum(:up_to_page) || 0
    total_pages = task.book.total_pages

    left_days = self.left_days(task)
    daily_goal_pages = self.daily_goal_pages(task, max_read_up_to_page, total_pages) || 0
    today_page_number = self.today_page_number(task, max_read_up_to_page, total_pages)
    percentage = self.percentage(max_read_up_to_page, total_pages) || 0

    progress_data.push(
      {
        left_days: left_days,
        daily_goal_pages: daily_goal_pages,
        today_page_number: today_page_number,
        percentage: percentage,
      }
    )
  end

  # タスク一覧ページ
  # 進捗のデータをハッシュに整形
  def self.progress_data(tasks)
    progress_data = []

    tasks.each do |task|
      self.cul_progress_data(task, progress_data)
    end
    return progress_data
  end

  # タスク詳細ページ
  def self.task_progress_data(task)
    progress_data = []
    self.cul_progress_data(task, progress_data)
  end
end