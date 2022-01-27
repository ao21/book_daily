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

  # tasks.controller.rb で呼び出すもの
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

  # 進捗データを計算
  def self.calculate_tasks_percentage(task, tasks_percentage)
    max_read_up_to_page = task.reads.select(:up_to_page).maximum(:up_to_page) || 0
    total_pages = task.book.total_pages

    if max_read_up_to_page
      percentage = 100 * max_read_up_to_page / total_pages
    else
      percentage = 0
    end

    tasks_percentage.push(
      {
        read: percentage, unread: 100 - percentage
      }
    )
  end

  # 進捗のデータをハッシュに整形
  def self.tasks_percentage(tasks)
    tasks_percentage = []

    tasks.each do |task|
      self.calculate_tasks_percentage(task, tasks_percentage)
    end
    return tasks_percentage
  end

  # TaskShowページ

  def self.task_percentage(task)
    task_percentage = []
    self.calculate_tasks_percentage(task, task_percentage)
  end
end