class SourcesController < ApplicationController
  before_action :authenticate_user!
  respond_to :js

  require 'will_paginate/array'

  def index
    @source = Source.new
    @category = Category.new

    if params[:friend_id] == nil
      @user = current_user
      @musics = @user.musics
      @search_js = params[:search]

      if params[:category_id] == nil

        if params[:search] && params[:search].length >= 1
          sources = @user.sources.basic_search(title: params[:search])
          @sources = @user.musics.where(source_id: sources.map(&:id)).order('id DESC').map(&:source).paginate(:page => params[:page], :per_page => 30)
        else
          @sources = @user.musics.order('id DESC').map(&:source).paginate(:page => params[:page], :per_page => 12)
        end

      else
        category = Category.find(params[:category_id])

        if category.user_id == @user.id
          if params[:search] && params[:search].length >= 1
            sources = @user.sources.basic_search(title: params[:search])
            @sources = @user.musics.where(source_id: sources.map(&:id)).order('id DESC').map(&:source).paginate(:page => params[:page], :per_page => 12)
          else
            @sources = category.categorizations.map(&:music).sort_by { |h| -h[:id] }.map(&:source).paginate(:page => params[:page], :per_page => 12)
          end
        end
      end

    else
      friend_uid = Friend.find(params[:friend_id]).friend_uid
      @friend_id = Friend.find(params[:friend_id]).id
      @friend = User.where(:uid => friend_uid).first
      @musics = @friend.musics

      if params[:category_id] == nil

        if params[:search] && params[:search].length >= 1
          sources = @friend.sources.basic_search(title: params[:search])
          @sources = @friend.musics.where(source_id: sources.map(&:id)).order('id DESC').map(&:source).paginate(:page => params[:page], :per_page => 30)
        else
          @sources = @friend.musics.order('id DESC').map(&:source).paginate(:page => params[:page], :per_page => 12)
        end

      else
        category = Category.find(params[:category_id])

        if category.user_id == @friend.id
          if params[:search] && params[:search].length >= 1
            sources = @friend.sources.basic_search(title: params[:search])
            @sources = @friend.musics.where(source_id: sources.map(&:id)).order('id DESC').map(&:source).paginate(:page => params[:page], :per_page => 30)
          else
            @sources = category.categorizations.map(&:music).sort_by { |h| -h[:id] }.map(&:source).paginate(:page => params[:page], :per_page => 12)
          end
        end
      end

    end

  end

  def show
    @user = current_user
    @source = Source.find(params[:id])

    if params[:friend_id] == nil

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
        @musics = @user.musics.order('id DESC').paginate(:page => params[:page], :per_page => 10)

        respond_with do |format|
          format.html
          format.js
        end
      end

    else
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
          format.js { render "sources/musics_aside_friend" }
        end
      else
        @musics = @friend.musics.order('id DESC').paginate(:page => params[:page], :per_page => 10)

        respond_with do |format|
          format.html
          format.js
        end
      end
    end

  end

  def create
    @source = Source.new
    @url = params[:url]


    if @url[/^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/]
      create_youtube
    elsif @url[/^https?:\/\/(soundcloud.com|snd.sc)\/(.*)$/]
      create_soundcloud
    elsif @url[/^(?:https?:\/\/)?(?:www\.)?vibein.co\/(.*)$/]
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
      @source.url = video.embed_url
      @source.time = time(@source.duration)

      @source.save

    else
      @source = new_source
    end

    music_create
  end

  def create_soundcloud
    client = Soundcloud.new(:client_id => '7eda384a44d761c3108c153a6f9daa85')
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
    source_add = @url[/\d+$/]
    Music.create({:favorite => :false, :user_id => current_user.id, :source_id => source_add })
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

end
