require 'rails_helper'

RSpec.describe Task, type: :model do
  it "generates associated data from factory" do
    task = FactoryBot.build(:task)
    puts "This task's a book is #{task.book.inspect}"
    puts "This task's a user is #{task.user.inspect}"
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
        read = FactoryBot.create(:read, task_id: task1.id, read_page: "250")
        expect(book.total_pages).to be > read.read_page
        expect(Task.array_tasks_in_progress(user)).to include task1
      end
    end

    context "書籍ページ数が進捗ページ数より小さいとき" do
      it "タスクを配列に追加しないこと" do
        task2 = FactoryBot.create(:task, id: 2, book_id: book.id, user_id: user.id)
        read = FactoryBot.create(:read, task_id: task2.id, read_page: "550")
        expect(book.total_pages).to be <= read.read_page
        expect(Task.array_tasks_in_progress(user)).to_not include task2
      end
    end
  end
end
