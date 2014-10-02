class BookmarkletsController < ApplicationController
  before_action :authenticate_user!

  def index
    @source = Source.new
    @url = params[:url]

    if @url[/^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/]
      create_youtube
    elsif @url[/^https?:\/\/(soundcloud.com|snd.sc)\/(.*)$/]
      create_soundcloud
    end

    @source = Source.last

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