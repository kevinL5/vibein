class CategorizationsController < ApplicationController
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
    Categorization.find(params[:id]).destroy
    @music = Music.find(params[:music_id])

    respond_with do |format|
      format.html { redirect_to sources_path }
      format.js { render "subscription" }
    end
  end

end
