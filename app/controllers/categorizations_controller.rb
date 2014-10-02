class CategorizationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :js

  def create
    @music = Music.find(params[:music_id])
    @music.categorizations.create({category_id: params[:category_id]})

    respond_with do |format|
      format.html { redirect_to sources_path }
      format.js { render "subscription" }
    end
  end

  def destroy
    categorization = Categorization.find(params[:id])
    @music = categorization.music
    categorization.destroy

    respond_with do |format|
      format.html { redirect_to sources_path }
      format.js { render "subscription" }
    end
  end

end
