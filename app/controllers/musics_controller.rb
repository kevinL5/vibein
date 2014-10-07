class MusicsController < ApplicationController

 before_action :authenticate_user!

 def destroy
   @music = current_user.musics.where(:source_id => params[:id])
   @music.first.destroy
   redirect_to sources_path
 end

end