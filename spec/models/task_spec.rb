require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "バリデーション" do
    it "FactoryBotのデータがバリデーションを通ること" do
      expect(FactoryBot.build(:task)).to be_valid
    end
  end

  # self.array_tasks_in_progress(user)
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

  # self.calculate_days_left_until_finished_on(task)
  describe "タスク終了日までの残り日数を計算する" do
    context "タスクがnilのとき" do
      it "何も返さない" do
        task = nil
        expect(Task.calculate_days_left_until_finished_on(task)).to be nil
      end
    end

    context "タスク終了日が今日の日付よりn日前のとき" do
      it "0を返す" do
        n = rand(1000) + 1
        task = FactoryBot.build(:task, finished_on: Date.today.ago(n.days))
        expect(Task.calculate_days_left_until_finished_on(task)).to eq 0
      end
    end

    context "タスク終了日が今日の日付より1日前のとき" do
      it "0を返す" do
        task = FactoryBot.build(:task, finished_on: Date.today.ago(1.days))
        expect(Task.calculate_days_left_until_finished_on(task)).to eq 0
      end
    end

    context "タスク終了日が今日の日付と同じ場合" do
      it "1を返す" do
        task = FactoryBot.build(:task, finished_on: Date.today)
        expect(Task.calculate_days_left_until_finished_on(task)).to eq 1
      end
    end

    context "タスク終了日が今日の日付より1日先の場合" do
      it "2を返す" do
        task = FactoryBot.build(:task, finished_on: Date.today.since(1.days))
        expect(Task.calculate_days_left_until_finished_on(task)).to eq 2
      end
    end

    context "タスク終了日が今日の日付よりn日先の場合" do
      it "n+1を返す" do
        n = rand(1000) + 1
        task = FactoryBot.build(:task, finished_on: Date.today.since(n.days))
        expect(Task.calculate_days_left_until_finished_on(task)).to eq n+1
      end
    end
  end

  # self.calculate_target_pages_per_a_day(task)
  describe "1日あたりの目標ページ数を返す" do
    context "タスクがnilのとき" do
      it "何も返さない" do
        task = nil
        expect(Task.calculate_target_pages_per_a_day(task)).to be nil
      end
    end

    context "タスク終了日までの残り日数が0の場合" do
      context "昨日までに読んだ最大ページ数が存在する場合" do
        it "書籍の総ページ数 - 昨日までに読んだ最大ページ数 を返す" do
          book = FactoryBot.create(:book, total_pages: 500)
          task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.ago(1.days))
          read = FactoryBot.create(:read, task_id: task.id, up_to_page: 250, read_on: Date.today.ago(1.days))
          expect(Task.calculate_target_pages_per_a_day(task)).to eq 250
        end
      end

      context "昨日までに読んだ最大ページ数が0の場合" do
        it "書籍の総ページ数を返す" do
          book = FactoryBot.create(:book, total_pages: 500)
          task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.ago(1.days))
          read = FactoryBot.create(:read, task_id: task.id, up_to_page: 250, read_on: Date.today)
          expect(Task.calculate_target_pages_per_a_day(task)).to eq 500
        end
      end
    end

    context "タスク終了日までの残り日数が0以外の場合" do
      it "正しい数を返す" do
        book = FactoryBot.create(:book, total_pages: 550)
        task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(99.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 50, read_on: Date.today.ago(1.days))
        expect(Task.calculate_target_pages_per_a_day(task)).to eq 5
      end
    end
  end

  # self.decide_status_todays_target(task)
  describe "今日の目標に対するステータスを決める" do
    context "タスクの進捗データが存在しない場合" do
      it "残りページ数を返す" do
        book = FactoryBot.create(:book, total_pages: 500)
        task = FactoryBot.create(:task, book_id: book.id)
        expect((Task.decide_status_todays_target(task)).include?("ページ")).to be_truthy
      end
    end

    context "今日読んだ最大ページ番号が今日の目標ページ数と同じ" do
      it "DONEを返す" do
        book = FactoryBot.create(:book, total_pages: 505)
        task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(99.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 5, read_on: Date.today.ago(1.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 10    , read_on: Date.today)
        expect((Task.decide_status_todays_target(task)).include?("DONE")).to be_truthy
      end
    end

    context "今日読んだ最大ページ番号が今日の目標ページ数より大きい場合" do
      it "DONEを返す" do
        book = FactoryBot.create(:book, total_pages: 500)
        task = FactoryBot.create(:task, book_id: book.id, finished_on: Date.today.since(99.days))
        read = FactoryBot.create(:read, task_id: task.id, up_to_page: 6, read_on: Date.today)
        expect((Task.decide_status_todays_target(task)).include?("DONE")).to be_truthy
      end
    end
  end
end
