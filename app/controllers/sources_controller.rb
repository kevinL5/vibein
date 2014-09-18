class SourcesController < ApplicationController
  before_action :authenticate_user!
  respond_to :js

  def index

    @user = current_user
    @source = Source.new
    @category = Category.new

    @graph = Koala::Facebook::API.new(@user.token)

    profile = @graph.get_object("me")
    friends = @graph.get_connections("me", "friends")

    friends.each do |friend|
      if Friend.where('friend_uid' => friend.uid).first == nil
        Friend.create(user_id = current_user.uid, friend_id = friend.uid)
      end
    end


    if params[:search] && params[:search].length >= 1
      sources = @user.sources.basic_search(title: params[:search])
      @musics = @user.musics.where(source_id: sources.map(&:id))
    else
      @musics = @user.musics
    end

  end

  def show
    @user = current_user
    @source = Source.find(params[:id])

    if params[:search]
      if params[:search].length >= 1
        sources = @user.sources.basic_search(title: params[:search])
        @musics = @user.musics.where(source_id: sources.map(&:id))
      else
        @musics = @user.musics
      end

      respond_with do |format|
        format.html { redirect_to source_path(@source.id) }
        format.js { render "musics_aside" }
      end
    else
      @musics = @user.musics
    end
  end

  def create

    @source = Source.new
    @url = params[:url]

    if @url[/^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/]
      create_youtube
    elsif @url[/^https?:\/\/(soundcloud.com|snd.sc)\/(.*)$/]
      create_soundcloud
    end

    redirect_to sources_path

  end

  private

  def create_youtube
    video = VideoInfo.new(params[:url])

    @source.provider = video.provider
    @source.identification = video.video_id
    @source.title = video.title
    @source.duration = video.duration
    @source.uploaded = video.date
    @source.picture = video.thumbnail_large
    @source.time = time(@source.duration)

    @source.save

    music_create
  end

  def create_soundcloud
    client = Soundcloud.new(:client_id => '7eda384a44d761c3108c153a6f9daa85')
    track = client.get('/resolve', :url => @url)

    @source.provider = "Soundcloud"
    @source.identification = track.id
    @source.title = track.title
    @source.uploader = track.user.username
    @source.duration = track.duration / 1000
    @source.uploaded = track.date
    @source.picture = track.user.avatar_url
    @source.time = time(@source.duration)

    @source.save

    music_create
  end

  def time(duration)
    if duration.divmod(60)[1].to_s.length == 1
      sec = "0#{duration.divmod(60)[1]}"
    else
      sec = duration.divmod(60)[1]
    end

    if duration.divmod(60)[0] > 60
      if duration.divmod(60)[0].divmod(60)[1].to_s.length == 1
        min = "0#{duration.divmod(60)[0].divmod(60)[1]}"
      else
        min = duration.divmod(60)[0].divmod(60)[1]
      end
      hour = duration.divmod(60)[0].divmod(60)[0]
      return "#{hour}:#{min}:#{sec}"
    else
      return "#{duration.divmod(60)[0]}:#{sec}"
    end
  end

  def music_create
    Music.create({:favorite => :false, :user_id => current_user.id, :source_id => @source.id })
  end

  def source_params
    params.require(:source).permit(:provider, :identification, :title, :uploader, :duration, :uploaded, :picture)
  end

end
