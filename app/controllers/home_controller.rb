class HomeController < ApplicationController
  def index
    @reads_new = Read.includes([task: :user],[task: :book]).order(read_on: :desc).limit(50)
  end
end
