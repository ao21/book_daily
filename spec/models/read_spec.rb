require 'rails_helper'

RSpec.describe Read, type: :model do
  describe "バリデーション" do
    it "FactoryBotのデータがバリデーションを通ること" do
      expect(FactoryBot.build(:read)).to be_valid
    end

    it "read_onがない場合エラーになること" do
      read = FactoryBot.build(:read, read_on: nil)
      read.valid?
      expect(read.errors[:read_on]).to include("を入力してください")
    end

    it "up_to_pageがない場合エラーになること" do
      read = FactoryBot.build(:read, up_to_page: nil)
      read.valid?
      expect(read.errors[:up_to_page]).to include("を入力してください")
    end

    it "up_to_pageが文字列の場合エラーになること" do
      read = FactoryBot.build(:read, up_to_page: "test")
      read.valid?
      expect(read.errors[:up_to_page]).to include("は数値で入力してください")
    end

    it "up_to_pageが0の場合エラーになること" do
      read = FactoryBot.build(:read, up_to_page: 0)
      read.valid?
      expect(read.errors[:up_to_page]).to include("は0より大きい値にしてください")
    end

    it "up_to_pageが総ページ数より大きい場合エラーになること" do
      book = FactoryBot.create(:book, total_pages: 500)
      task = FactoryBot.create(:task, book_id: book.id)
      read = FactoryBot.build(:read, task_id: task.id, up_to_page: 600)
      read.valid?
      expect(read.errors[:up_to_page]).to include(": 総ページ数より大きい数は登録できません")
    end

    it "up_to_pageがすでに登録済みのup_to_pageの数より小さい場合エラーになること" do
      task = FactoryBot.create(:task)
      FactoryBot.create(:read, task_id: task.id, up_to_page: 60)
      read = FactoryBot.build(:read, task_id: task.id, up_to_page: 50)
      read.valid?
      expect(read.errors[:up_to_page]).to include(": 登録済みのページ番号より小さい数は登録できません")
    end
  end
end
