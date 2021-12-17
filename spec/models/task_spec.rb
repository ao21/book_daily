require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "バリデーション" do
    it "FactoryBotのデータがバリデーションを通ること" do
      expect(FactoryBot.build(:task)).to be_valid
    end
  end

  # Task.array_tasks_in_progress(user)
  describe "指定したユーザーが持つ進行中のタスクの配列を返す" do
    let(:user) { FactoryBot.create(:user) }

    it "タスクを持たないとき、空の配列を返すこと" do
      expect(Task.array_tasks_in_progress(user)).to be_empty
    end

    it "タスクが進捗データを持たないとき、タスクが配列に追加されること" do
      task = FactoryBot.create(:task, user_id: user.id)
      expect(task.reads).to be_empty
      expect(Task.array_tasks_in_progress(task.user)).to include task
    end

    let(:book) { FactoryBot.create(:book, total_pages: "500") }

    context "書籍ページ数が進捗ページ数より大きいとき" do
      it "タスクを配列に追加すること" do
        task1 = FactoryBot.create(:task, id: 1, book_id: book.id, user_id: user.id)
        read = FactoryBot.create(:read, task_id: task1.id, up_to_page: "250")
        expect(book.total_pages).to be > read.up_to_page
        expect(Task.array_tasks_in_progress(user)).to include task1
      end
    end

    context "書籍ページ数が進捗ページ数と同じ" do
      it "タスクを配列に追加しないこと" do
        task2 = FactoryBot.create(:task, id: 2, book_id: book.id, user_id: user.id)
        read = FactoryBot.create(:read, task_id: task2.id, up_to_page: "500")
        expect(book.total_pages).to be <= read.up_to_page
        expect(Task.array_tasks_in_progress(user)).to_not include task2
      end
    end
  end

  # Task.calculate_days_left_until_finished_on(task)
  describe "タスク終了日までの残り日数を計算する" do
    context "タスク終了日が今日の日付よりn日前のとき" do
      it "0を返すこと" do
        n = rand(1000) + 1
        task = FactoryBot.build(:task, finished_on: Date.today.ago(n.days))
        expect(Task.calculate_days_left_until_finished_on(task)).to eq 0
      end
    end

    context "タスク終了日が今日の日付より1日前のとき" do
      it "0を返すこと" do
        task = FactoryBot.build(:task, finished_on: Date.today.ago(1.days))
        expect(Task.calculate_days_left_until_finished_on(task)).to eq 0
      end
    end

    context "タスク終了日が今日の日付と同じ場合" do
      it "1を返すこと" do
        task = FactoryBot.build(:task, finished_on: Date.today)
        expect(Task.calculate_days_left_until_finished_on(task)).to eq 1
      end
    end

    context "タスク終了日が今日の日付より1日先の場合" do
      it "2を返すこと" do
        task = FactoryBot.build(:task, finished_on: Date.today.since(1.days))
        expect(Task.calculate_days_left_until_finished_on(task)).to eq 2
      end
    end

    context "タスク終了日が今日の日付よりn日先の場合" do
      it "n+1を返すこと" do
        n = rand(1000) + 1
        task = FactoryBot.build(:task, finished_on: Date.today.since(n.days))
        expect(Task.calculate_days_left_until_finished_on(task)).to eq n+1
      end
    end
  end

  # Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)
  describe "1日あたりの目標ページ数を返す" do
    context "タスク終了日までの残り日数が0の場合" do
      context "昨日までに読んだ最大ページ数が存在する場合" do
        it "書籍の総ページ数 - 昨日までに読んだ最大ページ数 を返すこと" do
          book = FactoryBot.create(:book, total_pages: 500)
          task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.ago(1.days))
          read = FactoryBot.create(:read, task_id: task.id, up_to_page: 250, read_on: Date.today.ago(1.days))

          days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
          max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0

          expect(Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)).to eq 250
        end
      end

      context "昨日までに読んだ最大ページ数が0の場合" do
        it "書籍の総ページ数を返すこと" do
          book = FactoryBot.create(:book, total_pages: 500)
          task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.ago(1.days))
          read = FactoryBot.create(:read, task_id: task.id, up_to_page: 250, read_on: Date.today)

          days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
          max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
         
          expect(Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)).to eq 500
        end
      end
    end

    context "タスク終了日までの残り日数が0以外の場合" do
      it "正しい数を返すこと" do
        book = FactoryBot.create(:book, total_pages: 550)
        task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(99.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 50, read_on: Date.today.ago(1.days))

        days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
        max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
        
        expect(Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)).to eq 5
      end
    end
  end

  #  Task.calculate_todays_target_up_to_page(target_pages_per_a_day, max_read_up_to_page_until_yesterday)
  describe "今日の目標ページ番号を返す" do
    it "1日あたりのページ数と昨日までに読んだページ番号の最大値の和を返すこと" do
      book = FactoryBot.create(:book, total_pages: 500)
      task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(1.days))
      read = FactoryBot.create(:read, task_id: task.id, up_to_page: 100, read_on: Date.today.ago(1.days))

      days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
      max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
      target_pages_per_a_day = Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)
      
      expect(Task.calculate_todays_target_up_to_page(target_pages_per_a_day, max_read_up_to_page_until_yesterday)).to eq 300
    end

    context "昨日までに読んだページ番号が存在しないとき" do
      it "1日あたりのページ数を返すこと" do
        book = FactoryBot.create(:book, total_pages: 500)
        task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(1.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 100, read_on: Date.today)

        days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
        max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
        target_pages_per_a_day = Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)
       
        expect(Task.calculate_todays_target_up_to_page(target_pages_per_a_day, max_read_up_to_page_until_yesterday)).to eq target_pages_per_a_day
      end
    end
  end

  # Task.calculate_pages_left_to_todays_taget(target_pages_per_a_day, max_read_up_to_page_today)
  describe "今日の目標に対する残りのページ数を計算する" do
    it "1日あたりの目標ページ数と今日読んだページ番号の最大値の差を返すこと" do
      book = FactoryBot.create(:book, total_pages: 500)
      task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(1.days))
      read = FactoryBot.create(:read, task_id: task.id, up_to_page: 100, read_on: Date.today)

      days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
      max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
      max_read_up_to_page_today = "Read".constantize.where(task_id: task.id).where("read_on = ?", Date.today).maximum(:up_to_page) || 0
      target_pages_per_a_day = Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)

      expect(Task.calculate_pages_left_to_todays_taget(target_pages_per_a_day, max_read_up_to_page_today)).to eq 150
    end
    
    context "今日読んだページ番号のデータがない場合" do
      it "1日あたりの目標ページ数を返すこと" do
        book = FactoryBot.create(:book, total_pages: 500)
        task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(1.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 100, read_on: Date.today.ago(1.days))

        days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
        max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
        max_read_up_to_page_today = "Read".constantize.where(task_id: task.id).where("read_on = ?", Date.today).maximum(:up_to_page) || 0
        target_pages_per_a_day = Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)

        expect(Task.calculate_pages_left_to_todays_taget(target_pages_per_a_day, max_read_up_to_page_today)).to eq target_pages_per_a_day
      end
    end
  end

  # Task.decide_status_todays_target(todays_target_up_to_page, max_read_up_to_page_today, pages_left_to_todays_target)
  describe "今日の目標に対するステータスを決める" do
    context "タスクの進捗データが存在しない場合" do
      it "残りページ数を返すこと" do
        book = FactoryBot.create(:book, total_pages: 500)
        task = FactoryBot.create(:task, book_id: book.id)

        max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
        max_read_up_to_page_today = "Read".constantize.where(task_id: task.id).where("read_on = ?", Date.today).maximum(:up_to_page) || 0
        days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
        target_pages_per_a_day = Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)
        todays_target_up_to_page = Task.calculate_todays_target_up_to_page(target_pages_per_a_day, max_read_up_to_page_until_yesterday)
        pages_left_to_todays_target = Task.calculate_pages_left_to_todays_taget(target_pages_per_a_day, max_read_up_to_page_today)

        expect((Task.decide_status_todays_target(todays_target_up_to_page, max_read_up_to_page_today, pages_left_to_todays_target)).include?("ページ")).to be_truthy
      end
    end

    context "今日読んだ最大ページ番号が今日の目標ページ数と同じ" do
      it "DONEを返すこと" do
        book = FactoryBot.create(:book, total_pages: 505)
        task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(99.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 5, read_on: Date.today.ago(1.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 10, read_on: Date.today)

        max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
        max_read_up_to_page_today = "Read".constantize.where(task_id: task.id).where("read_on = ?", Date.today).maximum(:up_to_page) || 0
        days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
        target_pages_per_a_day = Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)
        todays_target_up_to_page = Task.calculate_todays_target_up_to_page(target_pages_per_a_day, max_read_up_to_page_until_yesterday)
        pages_left_to_todays_target = Task.calculate_pages_left_to_todays_taget(target_pages_per_a_day, max_read_up_to_page_today)

        expect((Task.decide_status_todays_target(todays_target_up_to_page, max_read_up_to_page_today, pages_left_to_todays_target)).include?("DONE")).to be_truthy
      end
    end

    context "今日読んだ最大ページ番号が今日の目標ページ数より大きい場合" do
      it "DONEを返すこと" do
        book = FactoryBot.create(:book, total_pages: 500)
        task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(99.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 6, read_on: Date.today)

        max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
        max_read_up_to_page_today = "Read".constantize.where(task_id: task.id).where("read_on = ?", Date.today).maximum(:up_to_page) || 0
        days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
        target_pages_per_a_day = Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)
        todays_target_up_to_page = Task.calculate_todays_target_up_to_page(target_pages_per_a_day, max_read_up_to_page_until_yesterday)
        pages_left_to_todays_target = Task.calculate_pages_left_to_todays_taget(target_pages_per_a_day, max_read_up_to_page_today)

        expect((Task.decide_status_todays_target(todays_target_up_to_page, max_read_up_to_page_today, pages_left_to_todays_target)).include?("DONE")).to be_truthy
      end
    end

    context "今日読んだ最大ページ番号が今日の目標ページ数より小さい場合" do
      it "残りページ数を返すこと" do
        book = FactoryBot.create(:book, total_pages: 500)
        task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(99.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 3, read_on: Date.today)

        max_read_up_to_page_until_yesterday = "Read".constantize.where(task_id: task.id).where("read_on < ?", Date.today).maximum(:up_to_page) || 0
        max_read_up_to_page_today = "Read".constantize.where(task_id: task.id).where("read_on = ?", Date.today).maximum(:up_to_page) || 0
        days_left_until_finished_on = Task.calculate_days_left_until_finished_on(task)
        target_pages_per_a_day = Task.calculate_target_pages_per_a_day(task, days_left_until_finished_on, max_read_up_to_page_until_yesterday)
        todays_target_up_to_page = Task.calculate_todays_target_up_to_page(target_pages_per_a_day, max_read_up_to_page_until_yesterday)
        pages_left_to_todays_target = Task.calculate_pages_left_to_todays_taget(target_pages_per_a_day, max_read_up_to_page_today)

        expect((Task.decide_status_todays_target(todays_target_up_to_page, max_read_up_to_page_today, pages_left_to_todays_target)).include?("2ページ")).to be_truthy
      end
    end
  end

  # self.calculate_achievement_rate_todays_target(max_read_up_to_page_today, max_read_up_to_page_until_yesterday, target_pages_per_a_day)
  describe "今日の目標の達成率を計算する" do
    context "" do
    end
  end
end
