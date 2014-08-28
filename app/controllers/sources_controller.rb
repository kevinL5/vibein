class SourcesController < ApplicationController

  before_action :authenticate_user!

  def index
    @user = current_user
    @source = Source.new

    if params[:search] && params[:search].length >= 1
      @sources = @user.sources.basic_search(title: params[:search])
    else
      @sources = @user.sources
    end

  end

  def show
    @user = current_user
    @sources = @user.sources
    @source = Source.find(params[:id])

  end

  def create

    @source = Source.new
    @url = params[:url]

    if @url[/^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/]
      create_youtube
    elsif @url[/^https?:\/\/(soundcloud.com|snd.sc)\/(.*)$/]
      create_soundcloud
    else
      create_link
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

    @source.save

    music_create
  end

  def create_link
  end

  def music_create
    Music.create({:favorite => :false, :user_id => current_user.id, :source_id => @source.id })
  end

  def source_params
    params.require(:source).permit(:provider, :identification, :title, :uploader, :duration, :uploaded, :picture)
  end

end
