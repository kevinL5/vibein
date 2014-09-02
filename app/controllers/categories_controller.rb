class CategoriesController < ApplicationController

   def show
    @user = current_user
    @source = Source.new
    @category = Category.new
    category = Category.find(params[:id])
    @musics = category.categorizations.map(&:music).map(&:source)
  end

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
