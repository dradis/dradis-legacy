module Dradis
  class CategoriesController < AuthenticatedController
    before_filter :find_or_initialize_model, :except => [ :index ]

    # GET /categories
    # GET /categories.json
    def index
      @categories = Category.all
      respond_to do |format|
        # format.html
        format.json { render json: @categories }
      end
    end

    def create
      @category.save
    end

    private
    def find_or_initialize_model
      if params[:id]
        unless @category = Category.find_by_id(params[:id])
          render_optional_error_file :not_found
        end
      else
        @category = Category.new(params[:category] || ActiveSupport::JSON.decode(params[:data]))
      end
      # TODO
      # @category.updated_by = current_user
    end
  end
end