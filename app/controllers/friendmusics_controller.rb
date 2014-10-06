class FriendmusicsController < ApplicationController
  before_action :authenticate_user!

  def index
    friend_uid = Friend.find(params[:friend_id]).friend_uid
    @friend_id = Friend.find(params[:friend_id]).id
    @friend = User.where(:uid => friend_uid).first
    @source = Source.new
    @musics = @friend.musics
    @category = Category.new


    if params[:search] && params[:search].length >= 1
      sources = @friend.sources.basic_search(title: params[:search])
      @sources = @friend.musics.where(source_id: sources.map(&:id)).map(&:source).sort_by { |h| h[:id] }
    else
      @sources = @friend.musics.map(&:source).sort_by { |h| h[:id] }
    end

  end

  def show
    friend_uid = Friend.find(params[:friend_id]).friend_uid
    @friend_id = Friend.find(params[:friend_id]).id
    @friend = User.where(:uid => friend_uid).first
    @source = Source.find(params[:id])

    if params[:search]
      if params[:search].length >= 1
        sources = @friend.sources.basic_search(title: params[:search])
        @musics = @friend.musics.where(source_id: sources.map(&:id))
      else
        @musics = @friend.musics.map(&:source)
      end

      respond_with do |format|
        format.html { redirect_to source_path(@source.id) }
        format.js { render "sources/musics_aside" }
      end
    else
      @musics = @friend.musics
    end
  end

end
