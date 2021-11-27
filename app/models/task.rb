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

  # TaskTodayページ

  def self.array_tasks_in_progress(user)
    array_tasks_in_progress = []
    tasks = user.tasks.all
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

  # tasks_controller.rb で呼び出す配列
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

  # TaskIndexページ

  def self.calculate_percentage(max_read_up_to_page, total_pages)
    if max_read_up_to_page
       100 * max_read_up_to_page / total_pages
    else
      0
    end
  end

  # 進捗データを計算
  def self.calculate_tasks_data(task, progress_data)
    max_read_up_to_page = task.reads.select(:up_to_page).maximum(:up_to_page) || 0
    total_pages = task.book.total_pages

    if max_read_up_to_page
      percentage = 100 * max_read_up_to_page / total_pages
    else
      percentage = 0
    end

    if percentage == 100
      status = 'done'
    else
      status = 'progress'
    end

    progress_data.push(
      {
        percentage: {read: percentage, unread: 100 - percentage},
        status: status
      }
    )
  end

  # 進捗のデータをハッシュに整形
  def self.tasks_data(tasks)
    progress_data = []

    tasks.each do |task|
      self.calculate_tasks_data(task, progress_data)
    end
    return progress_data
  end

  # タスク一覧ページ

  # タスク詳細ページ
  def self.task_progress_data(task)
    progress_data = []
    self.cul_progress_data(task, progress_data)
  end
end