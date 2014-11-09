class PublicController < ApplicationController
  #This controller haven't authentification required - It's allow users who aren't signin to listen some of their friends' musics
  def index
    @source = Source.find(params[:source_id])
  end
end
