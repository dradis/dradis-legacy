module Dradis
  class CategoriesController < AuthenticatedController
    before_filter :find_model

    # GET /categories
    # GET /categories.json
    def index
      @categories = Category.all
      respond_to do |format|
        # format.html
        format.json { render json: @categories }
      end
    end


    private
    def find_model
      @category = Categories.find(params[:id]) if params[:id]
    end
  end
end