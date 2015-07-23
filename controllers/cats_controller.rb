require_relative '../models/cat'
require_relative '../controller_logic/controller_base'

class CatsController < ControllerBase
  def create
    @cat = Cat.new(cat_params)
    if @cat.save
      redirect_to("/cats")
    else
      render :new
    end
  end

  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def show
    @cat = Cat.find(params["id"])
    render :show
  end

  private

  def cat_params
    params["cat"]
  end
end
