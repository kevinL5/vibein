class CategorizationsController < ApplicationController

  def create
    Categorization.create({music_id: params[:music_id], category_id: params[:category_id]})
    redirect_to sources_path
  end

end
