class Read < ApplicationRecord
  belongs_to :task
  has_one :user, through: :task

  # バリデーション
  validates :read_on, presence: true
  validates :up_to_page, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validate :validate_up_to_page_with_total_pages,
    :validate_up_to_page_with_saved_up_to_page,
    :validate_up_to_page_and_read_on

  def validate_up_to_page_with_total_pages
    if up_to_page.present? && up_to_page > task.book.total_pages
      errors.add(:up_to_page, ": 総ページ数より大きい数は登録できません")
    end
  end

  def validate_up_to_page_with_saved_up_to_page
    max_read_up_to_page = "Read".constantize.where(task_id: task.id).maximum(:up_to_page) || 0
    if up_to_page.present? && up_to_page <= max_read_up_to_page
      errors.add(:up_to_page, ": 登録済みのページ番号より小さい数は登録できません")
    end
  end

  def validate_up_to_page_and_read_on
    read = task.reads.order(up_to_page: :desc).order(read_on: :desc).limit(1)
    if read.present?
      max_read_up_to_page = read[0].up_to_page
      date_max_read_up_to_page = read[0].read_on
      if up_to_page.present? && read_on.present? && up_to_page > max_read_up_to_page && date_max_read_up_to_page > read_on
        errors.add(:up_to_page, ": すでに過去の日付でより大きいページ番号が登録されています")
      end
    end
  end

  # タスク一覧ページの SimpleCalendar で使用
  def start_time
    self.read_on
  end

  # 1ヶ月間の最大ページ、読んだページ、読んだ冊数を計算
  def self.cal_month_data(user, time)
    this_month_read = user.reads.where(read_on: time.all_month)
    if this_month_read.present?
      max_page = this_month_read.group(:task_id).maximum(:up_to_page)
      max_page_last = "Read".constantize.where(task_id: max_page.keys).where(read_on: time.advance(months: -1).all_month).group(:task_id).maximum(:up_to_page)

      if max_page_last.present?
        read_page = max_page.merge(max_page_last){|k, v1, v2| v1 - v2}
      else
        read_page = max_page
      end
      read_pages = read_page.values.inject(:+)

      # 読んだ冊数を計算
      tasks = Task.includes(:book).where(id: max_page.keys).pluck(:book_id)
      total_pages = Book.where(id: tasks).pluck(:total_pages)
      read_book = 0
      total_pages.zip(max_page.values) do |total_pages, max_page|
        total_pages == max_page ? read_book += 1 : read_book += 0
      end
    else
      max_page = 0
      read_pages = 0
      read_book = 0
    end

    # 1日あたりのページ数を計算
    month_days = [*Date.today.all_month].size
    day_pages = read_pages / month_days

    data = {
      read_pages: read_pages,
      read_book: read_book,
      day_pages: day_pages
    }
  end

  # 今月と先月の最大ページ、読んだページを準備
  def self.month_data(user)
    time = Time.now
    this_month_data = self.cal_month_data(user, time)

    time = Time.now.advance(months: -1)
    last_month_data = self.cal_month_data(user, time)

    month_data = {
      this_month: this_month_data,
      last_month: last_month_data
    }
    return month_data
  end

  def self.reads_percentage(reads, task)
    reads_percentage = {}
    if reads
      reads.reverse.each do |read|
          percentage = 100 * read.up_to_page / task.book.total_pages
          reads_percentage.store(
            read.read_on,
            percentage
          )
      end
    end
    return reads_percentage
  end
end
