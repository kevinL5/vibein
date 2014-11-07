class BookmarkletsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @source = Source.new
    @category = Category.new

    show_friends
  end

  private

  def show_friends
    @friends = @user.friends

    if @user.provider == 'facebook'
      graph = Koala::Facebook::API.new(@user.token)
      @fb_friends = graph.get_connections("me", "friends")

      @fb_friends.each do |fb_friend|
        if @friends.where(:friend_uid => fb_friend["id"]).first == nil
          Friend.create(friend_uid: fb_friend["id"], user_id: @user.id.to_i)
        end
      end
    end
  end

end
