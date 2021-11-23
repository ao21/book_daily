class Task < ApplicationRecord
  belongs_to :book
  belongs_to :user
  has_many :reads, dependent: :destroy

  # バリデーション
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

    if days_left_until_finished_on <= 0
      days_left_until_finished_on = 0
    else
      days_left_until_finished_on
    end
  end

  def self.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)
    book_total_pages = task.book.total_pages

    if days_left_until_finished_on == 0
      target_pages_per_a_day = book_total_pages - max_read_up_to_page_until_yesterday
    else
      target_pages_per_a_day = ((book_total_pages - max_read_up_to_page_until_yesterday) / days_left_until_finished_on.to_f).ceil
    end
  end

  def self.calculate_todays_target_up_to_page(target_pages_per_a_day, max_read_up_to_page_until_yesterday)
    todays_target_up_to_page = target_pages_per_a_day + max_read_up_to_page_until_yesterday
  end

  def self.calculate_pages_left_to_todays_taget(target_pages_per_a_day, max_read_up_to_page_today)
    pages_left_to_todays_target = target_pages_per_a_day - max_read_up_to_page_today
  end

  def self.decide_status_todays_target(todays_target_up_to_page, max_read_up_to_page_today, pages_left_to_todays_target)
    status_todays_target = {}
    if todays_target_up_to_page <= max_read_up_to_page_today
      status_todays_target = { color: "main", status: "DONE"}
    else
      status_todays_target = { color: "second", status: "あと#{pages_left_to_todays_target}ページ"}
    end
    return status_todays_target
  end

  def self.array_read_data_this_week(task, target_pages_per_a_day)
    # 今日を起点とした今週の範囲を設定する
    today = Date.today
    day_of_the_week = today.wday

    from = today.prev_occurring(:monday)
    to = today.next_occurring(:sunday)
    if day_of_the_week == 1
      from = today
    elsif day_of_the_week == 0
      to = today
    end

    each_date = []
    reads = "Read".constantize.where(task_id: task.id, read_on: from...to)
    (from..to).each do |date|
      reads_on_date = reads.select { |read| read.read_on == date }
      if reads_on_date.present?
        each_date.push(" --main")
      else
        each_date.push(nil)
      end
    end

    this_weeks = {}
    (from..to).to_a.zip(each_date) do |date, per|
      this_weeks.store(date, per)
    end
    return this_weeks
  end

  def self.todays_page_data(task)
    if task
      max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
      max_read_up_to_page_today = "Read".constantize.where(task_id: task.id).where("read_on = ?", Date.today).maximum(:up_to_page) || 0

      # 計算メソッドの呼び出し変数をセット
      days_left_until_finished_on = self.calculate_days_left_until_finished_on(task)
      target_pages_per_a_day = self.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)
      todays_target_up_to_page = self.calculate_todays_target_up_to_page(target_pages_per_a_day, max_read_up_to_page_until_yesterday)
      pages_left_to_todays_target = self.calculate_pages_left_to_todays_taget(target_pages_per_a_day, max_read_up_to_page_today)
      status_todays_target = self.decide_status_todays_target(todays_target_up_to_page, max_read_up_to_page_today, pages_left_to_todays_target)
      array_read_data_this_week = self.array_read_data_this_week(task, target_pages_per_a_day)

      todays_target = {
        up_to_page: todays_target_up_to_page,
        status: status_todays_target,
        read_data: array_read_data_this_week
      }
      return todays_target
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
    left_days = (task.finished_on - Date.today + 1).to_i
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
      if new_read.length == 2 && new_read[0].read_on == Date.today
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