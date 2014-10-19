class CategoriesController < ApplicationController
  before_action :authenticate_user!

  def create
    if current_user.categories.length < 5
      current_user.categories.create(category_params)
    end
    redirect_to sources_path
  end

  def destroy
    Category.find(params[:id]).destroy
    redirect_to sources_path
  end


  private

  def category_params
    params.require(:category).permit(:title, :thumbnail)
  end
end
