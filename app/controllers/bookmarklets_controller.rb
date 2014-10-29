class BookmarkletsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @source = Source.new
    @category = Category.new
    end
end
