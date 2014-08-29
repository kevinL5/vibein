class CategoriesController < ApplicationController


  def create
    if current_user.categories.length < 5
      category_attributes = category_params.merge(thumbnail: "color")
      current_user.categories.create(category_attributes)
    end
    redirect_to sources_path
  end


  private

  def category_params
    params.require(:category).permit(:title, :thumbnail)
  end
end
