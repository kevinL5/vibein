class ApiController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @source = Source.new
    @url = params[:url]

    create

    show_friends

    @source = Source.where(:id => Music.last.source_id).first
  end

  def create

     if @url[/^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/]
      create_youtube
    elsif @url[/^https?:\/\/(soundcloud.com|snd.sc)\/(.*)$/]
      create_soundcloud
    elsif @url[/^(?:https?:\/\/)?(?:www\.)?localhost:3000\/(.*)$/]
      create_vibein
    end

  end

    private

  def create_youtube
    video = VideoInfo.new(params[:url])
    new_source = Source.where(:identification => video.video_id).first

    if new_source == nil

      @source.provider = video.provider
      @source.identification = video.video_id
      @source.title = video.title
      @source.duration = video.duration
      @source.uploaded = video.date
      @source.picture = video.thumbnail_large
      @source.url = "https:" + video.embed_url
      @source.time = time(@source.duration)

      @source.save

    else
      @source = new_source
    end

    music_create
  end

  def create_soundcloud
    client = Soundcloud.new(:client_id => ENV['SOUDCLOUD_CLIENT_ID'])
    track = client.get('/resolve', :url => @url)
    new_source = Source.where(:identification => track.id.to_s).first

    if new_source == nil

      @source.provider = "Soundcloud"
      @source.identification = track.id
      @source.title = "#{track.user.username} - #{track.title}"
      @source.uploader = track.user.username
      @source.duration = track.duration / 1000
      @source.uploaded = track.date
      @source.picture = track.user.avatar_url
      @source.url = track.permalink_url
      @source.time = time(@source.duration)

      @source.save

    else
      @source = new_source
    end

    music_create
  end

  def create_vibein
    @source_add = @url[/\d+$/]
    Music.create({:favorite => :false, :playback => 1, :user_id => current_user.id, :source_id => @source_add.to_i })
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
    Music.create({:favorite => :false, :playback => 1, :user_id => current_user.id, :source_id => @source.id })
  end

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