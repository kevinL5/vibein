class MusicsController < ApplicationController

  before_action :authenticate_user!

  def destroy
    @music = current_user.musics.find(params[:id])
    @music.destroy
    redirect_to sources_path
  end

end
