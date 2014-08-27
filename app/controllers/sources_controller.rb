class SourcesController < ApplicationController

  before_action :authenticate_user!

  def index
    @user = current_user
    @sources = @user.sources !!!!!!!!!!!!!!!
    @source = Source.new
  end

  def show
    @user = current_user
    @sources = @user.sources !!!!!!!!!!!!!!!!!
    @source = Source.find(params[:id])
  end

  def create

    @source = Source.new

    video = VideoInfo.new(params[:url])

    @source.provider = video.provider
    @source.identification = video.video_id
    @source.title = video.title
    @source.duration = video.duration
    @source.uploaded = video.date
    @source.picture = video.thumbnail_large

    @source.save

    Music.create({:favorite => :false, :user_id => current_user.id, :source_id => @source.id })

    redirect_to sources_path
  end

  def destroy
  end

  private

  def source_params
    params.require(:source).permit(:provider, :identification, :title, :uploader, :duration, :uploaded, :picture)
  end

end
