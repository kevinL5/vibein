class SourcesController < ApplicationController

  before_action :authenticate_user!

  def index
    @sources = Source.all
    @source = Source.new
  end

  def show
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

    redirect_to sources_path
  end

  def destroy
  end

  private

  def source_params
    params.require(:source).permit(:provider, :identification, :title, :uploader, :duration, :uploaded, :picture)
  end

end
