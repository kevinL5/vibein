class SourcesController < ApplicationController
  before_action :authenticate_user!
  respond_to :js



  def index
    @user = current_user
    @source = Source.new
    @category = Category.new

    show_friends #Check if user have new friends who joined Vibe in - display in navbar

    if params[:friend_id] == nil #User request for his own musics
      @user = current_user
      @musics = @user.musics
      @search_js = params[:search]

      if params[:category_id] == nil
        @sources = Kaminari.paginate_array(@user.musics.order('id DESC').map(&:source)).page(params[:page]).per(12)
      else
        category = Category.find(params[:category_id])

        if category.user_id == @user.id
          @sources = Kaminari.paginate_array(category.categorizations.map(&:music).sort_by { |h| -h[:id] }.map(&:source)).page(params[:page]).per(12)
        end
      end

    else #User request for his friend's musics
      friend_uid = Friend.find(params[:friend_id]).friend_uid
      @friend_id = Friend.find(params[:friend_id]).id
      @friend = User.where(:uid => friend_uid).first
      @musics = @friend.musics

      if params[:category_id] == nil
        @sources = Kaminari.paginate_array(@friend.musics.order('id DESC').map(&:source)).page(params[:page]).per(12)
      else
        category = Category.find(params[:category_id])

        if category.user_id == @friend.id
          @sources = Kaminari.paginate_array(category.categorizations.map(&:music).sort_by { |h| h[:id] }.map(&:source)).page(params[:page]).per(12)
        end
      end
    end

  end

  def show
    @user = current_user
    @source = Source.find(params[:id])

    show_friends #Check if user have new friends who joined Vibe in - display in navbar

    if params[:friend_id] == nil #User request to play a music from his playlist
      @musics = Kaminari.paginate_array(@user.musics.order('id DESC')).page(params[:page]).per(10)

      respond_with do |format|
        format.html
        format.js
      end

      playback_music #Increment the playback of the music

    else #User request to play a music from his friend's playlist
      friend_uid = Friend.find(params[:friend_id]).friend_uid
      @friend_id = Friend.find(params[:friend_id]).id
      @friend = User.where(:uid => friend_uid).first
      @source = Source.find(params[:id])

      @musics = Kaminari.paginate_array(@friend.musics.order('id DESC')).page(params[:page]).per(10)

      respond_with do |format|
        format.html
        format.js
      end
    end
    #Category (= params[:category_id]) will be check in the view - BAD !

  end

  def create
    @source = Source.new
    @url = params[:url]


    if @url[/^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/]
      create_youtube
    elsif @url[/^https?:\/\/(soundcloud.com|snd.sc)\/(.*)$/]
      create_soundcloud
    elsif @url[/^(?:https?:\/\/)?(?:www\.)?vibein.co\/(.*)$/] #When the music come from vibein.co
      create_vibein
    end

    redirect_to(:back)
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
    source_add = @url[/\d+$/] #Extract the last numbers of the url who are the source ID
    Music.create({:favorite => :false, :playback => 1, :user_id => current_user.id, :source_id => source_add })
  end

  def time(duration) #Transform the duration (in seconds) in HH:MM:SS timestamp
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

      @fb_friends.each do |fb_friend| #Check if the user have new friends
        if @friends.where(:friend_uid => fb_friend["id"]).first == nil
          Friend.create(friend_uid: fb_friend["id"], user_id: @user.id.to_i)
        end
      end
    end
  end

  def playback_music
    music = Music.where(:source_id => @source.id).where(:user_id => @user.id).first

    if Time.now - music.updated_at > 3600 #Not increment the playback if the user already played this music in the last hour
      futur_playback = music.playback += 1
      music.update(:playback => futur_playback)
    end
  end

end
