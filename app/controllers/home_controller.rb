class HomeController < ApplicationController
  def index
    @reads = Read.includes([task: :user],[task: :book]).order(read_on: :desc)
  end
end
