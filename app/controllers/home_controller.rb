class HomeController < ApplicationController

  # 定数
  MAX_READS = 50

  def index
    @reads_new = Read.includes([task: :user],[task: :book]).order(read_on: :desc).limit(MAX_READS)
  end
end
